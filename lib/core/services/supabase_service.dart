import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';

class SupabaseService extends GetxService {
  static SupabaseService get to => Get.find();
  
  final SupabaseClient client = Supabase.instance.client;

  // --- AUTH METHODS ---
  
  User? get currentUser => client.auth.currentUser;
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  Future<AuthResponse> signUp({required String email, required String password, required Map<String, dynamic> data}) async {
    return await client.auth.signUp(email: email, password: password, data: data);
  }

  Future<AuthResponse> signIn({required String email, required String password}) async {
    return await client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // --- DATABASE METHODS ---

  // Profiles
  Future<Map<String, dynamic>?> getProfile(String id) async {
    return await client.from('profiles').select().eq('id', id).single();
  }

  Future<Map<String, dynamic>> updateProfile(
    String id,
    Map<String, dynamic> payload,
  ) async {
    return await client
        .from('profiles')
        .update(payload)
        .eq('id', id)
        .select()
        .single();
  }

  Future<void> updatePassword(String newPassword) async {
    await client.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<String> uploadAvatar({
    required String userId,
    required Uint8List bytes,
    required String extension,
  }) async {
    final path = '$userId/avatar.$extension';
    await client.storage
        .from('avatars')
        .uploadBinary(path, bytes, fileOptions: const FileOptions(upsert: true));
    return client.storage.from('avatars').getPublicUrl(path);
  }

  // Categories
  Future<List<Map<String, dynamic>>> getCategories() async {
    return await client.from('categories').select().order('name');
  }

  // Outflows (Sorties de caisse)
  Future<List<Map<String, dynamic>>> getOutflows({int? limit}) async {
    var query = client
        .from('outflows')
        .select(
          '*, '
          'categories(*), '
          'profiles:profiles!outflows_user_id_fkey(*), '
          'validator_profile:profiles!outflows_validated_by_fkey(*)',
        )
        .order('created_at', ascending: false);
    
    if (limit != null) {
      query = query.limit(limit);
    }
    
    return await query;
  }

  // Dashboard Data
  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);

      final results = await Future.wait([
        getTotalByPeriod(dateStart: DateTime(2000), dateEnd: DateTime(2100), status: 'validated'),
        getTotalByPeriod(dateStart: DateTime(2000), dateEnd: DateTime(2100), status: 'pending'),
        getTotalByPeriod(dateStart: DateTime(2000), dateEnd: DateTime(2100), status: 'rejected'),
        getTotalByPeriod(dateStart: firstDayOfMonth, dateEnd: now, status: 'validated'),
      ]);

      final validated = results[0];
      final pending = results[1];
      final rejected = results[2];
      final thisMonth = results[3];

      return {
        'total_validated': validated['total_amount'] ?? 0,
        'count_validated': validated['total_count'] ?? 0,
        'total_pending': pending['total_amount'] ?? 0,
        'count_pending': pending['total_count'] ?? 0,
        'total_rejected': rejected['total_amount'] ?? 0,
        'count_rejected': rejected['total_count'] ?? 0,
        'total_this_month': thisMonth['total_amount'] ?? 0,
      };
    } catch (_) {
      // Fallback sans RPC: calcul direct depuis outflows
      final rows = await getOutflows();
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);

      double totalValidated = 0;
      double totalPending = 0;
      double totalRejected = 0;
      double totalThisMonth = 0;
      int countValidated = 0;
      int countPending = 0;
      int countRejected = 0;

      for (final row in rows) {
        final amount = (row['amount'] as num?)?.toDouble() ?? 0.0;
        final status = (row['status'] ?? '').toString();
        final rawDate = row['outflow_date'] ?? row['created_at'];
        final date = rawDate == null ? null : DateTime.tryParse(rawDate.toString());

        if (status == 'validated') {
          totalValidated += amount;
          countValidated++;
          if (date != null && !date.isBefore(firstDayOfMonth)) {
            totalThisMonth += amount;
          }
        } else if (status == 'pending') {
          totalPending += amount;
          countPending++;
        } else if (status == 'rejected') {
          totalRejected += amount;
          countRejected++;
        }
      }

      return {
        'total_validated': totalValidated,
        'count_validated': countValidated,
        'total_pending': totalPending,
        'count_pending': countPending,
        'total_rejected': totalRejected,
        'count_rejected': countRejected,
        'total_this_month': totalThisMonth,
      };
    }
  }

  Future<List<Map<String, dynamic>>> getCategorySummary() async {
    try {
      return await getStatsByCategory();
    } catch (_) {
      final rows = await getOutflows();
      final totals = <String, double>{};
      for (final row in rows) {
        final category = row['categories'] as Map<String, dynamic>?;
        final name = (category?['name'] ?? 'Sans catégorie').toString();
        final amount = (row['amount'] as num?)?.toDouble() ?? 0.0;
        totals[name] = (totals[name] ?? 0) + amount;
      }
      return totals.entries
          .map((e) => {'name': e.key, 'total_amount': e.value})
          .toList()
        ..sort((a, b) => (b['total_amount'] as double).compareTo(a['total_amount'] as double));
    }
  }

  Future<Map<String, dynamic>> createOutflow(Map<String, dynamic> data) async {
    // On génère le numéro de reçu via RPC avant l'insertion si possible, 
    // ou on laisse le trigger/default faire si configuré.
    // Ici on va appeler la fonction generate_receipt_no
    final String receiptNo = await client.rpc('generate_receipt_no');
    data['receipt_no'] = receiptNo;
    
    return await client.from('outflows').insert(data).select().single();
  }

  Future<dynamic> updateOutflowStatusRpc({
    required String outflowId,
    required String newStatus,
    required String userId,
    String? comment,
    String? reason,
  }) async {
    return await client.rpc('update_outflow_status', params: {
      'p_outflow_id': outflowId,
      'p_new_status': newStatus,
      'p_user_id': userId,
      'p_comment': comment,
      'p_reason': reason,
    });
  }

  // Statistiques & Rapports via RPC
  Future<List<Map<String, dynamic>>> getStatsByCategory({DateTime? dateStart, DateTime? dateEnd}) async {
    final response = await client.rpc('get_stats_by_category', params: {
      'p_date_start': dateStart?.toIso8601String().split('T')[0],
      'p_date_end': dateEnd?.toIso8601String().split('T')[0],
    });
    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> getTotalByPeriod({
    required DateTime dateStart,
    required DateTime dateEnd,
    String? status,
  }) async {
    final response = await client.rpc('get_total_by_period', params: {
      'p_date_start': dateStart.toIso8601String().split('T')[0],
      'p_date_end': dateEnd.toIso8601String().split('T')[0],
      'p_status': status,
    });
    // get_total_by_period retourne une table, donc on prend la première ligne
    if (response is List && response.isNotEmpty) {
      return response.first;
    }
    return {};
  }

  Future<List<Map<String, dynamic>>> getMonthlyReport() async {
    // Cette fonction pourrait appeler un RPC ou faire une agrégation
    // Pour l'instant, on va simuler ou faire une requête groupée
    // On va récupérer les 6 derniers mois
    final now = DateTime.now();
    List<Map<String, dynamic>> report = [];
    
    for (int i = 5; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final monthEnd = DateTime(now.year, now.month - i + 1, 0);
      
      final stats = await getTotalByPeriod(
        dateStart: monthDate,
        dateEnd: monthEnd,
        status: 'validated'
      );
      
      report.add({
        'month': DateFormat('MMM').format(monthDate),
        'amount': stats['total_amount'] ?? 0.0,
      });
    }
    return report;
  }

  // Logs
  Future<void> logAction(Map<String, dynamic> logData) async {
    await client.from('outflow_logs').insert(logData);
  }
}
