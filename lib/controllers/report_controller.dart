// ================================
// 📁 lib/controllers/report_controller.dart
// Contrôleur pour les rapports et statistiques
// ================================

import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../core/services/supabase_service.dart';
import '../core/services/pdf_service.dart';

class ReportController extends GetxController {
  final _supabase = SupabaseService.to;
  final _pdfService = PdfService.to;

  // ── Variables observables ─────────────────────────
  final _isLoading = false.obs;
  final _monthlyReport = <Map<String, dynamic>>[].obs;
  final _categorySummary = <Map<String, dynamic>>[].obs;
  final _outflowsByStatus = <Map<String, dynamic>>[].obs;
  final _dateRangeStart = Rxn<DateTime>();
  final _dateRangeEnd = Rxn<DateTime>();
  final _selectedStatus = Rxn<String>();
  final _selectedCategory = Rxn<String>();
  final _errorMessage = ''.obs;
  final _selectedPeriod = 'month'.obs;
  final _periodStats = Rxn<Map<String, dynamic>>();
  final _categoryData = <Map<String, dynamic>>[].obs;

  // ── Getters ───────────────────────────────────────
  bool get isLoading => _isLoading.value;
  List<Map<String, dynamic>> get monthlyReport => _monthlyReport;
  List<Map<String, dynamic>> get categorySummary => _categorySummary;
  List<Map<String, dynamic>> get outflowsByStatus => _outflowsByStatus;
  DateTime? get dateRangeStart => _dateRangeStart.value;
  DateTime? get dateRangeEnd => _dateRangeEnd.value;
  String? get selectedStatus => _selectedStatus.value;
  String? get selectedCategory => _selectedCategory.value;
  String get errorMessage => _errorMessage.value;
  String get selectedPeriod => _selectedPeriod.value;
  Map<String, dynamic>? get periodStats => _periodStats.value;
  List<Map<String, dynamic>> get categoryData => _categoryData;

  @override
  void onInit() {
    super.onInit();
    // Charger les rapports par défaut
    _dateRangeStart.value = DateTime(DateTime.now().year, DateTime.now().month, 1);
    _dateRangeEnd.value = DateTime.now();
    chargerRapports();
  }

  /// Charger tous les rapports
  Future<void> chargerRapports() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      await Future.wait([
        _chargerRapportMensuel(),
        _chargerRapportParCategorie(),
        _chargerRapportParStatut(),
        _chargerStatsPeriode(),
      ]);
    } catch (e) {
      _errorMessage.value = 'Erreur lors du chargement des rapports: $e';
      Get.snackbar('Erreur', 'Impossible de charger les rapports');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Charger le rapport mensuel
  Future<void> _chargerRapportMensuel() async {
    try {
      final data = await _supabase.getMonthlyReport();
      _monthlyReport.assignAll(data);
    } catch (e) {
      print('Erreur rapport mensuel: $e');
    }
  }

  /// Charger le rapport par catégorie
  Future<void> _chargerRapportParCategorie() async {
    try {
      final data = await _supabase.getStatsByCategory(
        dateStart: _dateRangeStart.value,
        dateEnd: _dateRangeEnd.value,
      );
      _categorySummary.assignAll(data);
      _categoryData.assignAll(_enrichCategoryPercentages(data));
    } catch (e) {
      print('Erreur rapport par catégorie: $e');
    }
  }

  Future<void> _chargerStatsPeriode() async {
    if (_dateRangeStart.value == null || _dateRangeEnd.value == null) return;
    final stats = await _supabase.getTotalByPeriod(
      dateStart: _dateRangeStart.value!,
      dateEnd: _dateRangeEnd.value!,
      status: null,
    );
    _periodStats.value = stats;
  }

  List<Map<String, dynamic>> _enrichCategoryPercentages(List<Map<String, dynamic>> raw) {
    final total = raw.fold<double>(
      0,
      (sum, row) => sum + ((row['total_amount'] as num?)?.toDouble() ?? 0),
    );
    return raw
        .map((row) {
          final amount = (row['total_amount'] as num?)?.toDouble() ?? 0.0;
          final percentage = total == 0 ? 0.0 : (amount / total) * 100;
          return {
            ...row,
            'percentage': percentage,
          };
        })
        .toList();
  }

  void changerPeriode(String value) {
    _selectedPeriod.value = value;
    final now = DateTime.now();
    switch (value) {
      case 'day':
        _dateRangeStart.value = DateTime(now.year, now.month, now.day);
        _dateRangeEnd.value = now;
        break;
      case 'week':
        _dateRangeStart.value = now.subtract(const Duration(days: 6));
        _dateRangeEnd.value = now;
        break;
      case 'year':
        _dateRangeStart.value = DateTime(now.year, 1, 1);
        _dateRangeEnd.value = now;
        break;
      case 'month':
      default:
        _dateRangeStart.value = DateTime(now.year, now.month, 1);
        _dateRangeEnd.value = now;
        break;
    }
    chargerRapports();
  }

  /// Charger le rapport par statut
  Future<void> _chargerRapportParStatut() async {
    try {
      final allOutflows = await _supabase.getOutflows();
      
      // Grouper par statut
      final byStatus = <String, int>{};
      final byStatusAmount = <String, double>{};
      
      for (var outflow in allOutflows) {
        final status = outflow['status'] ?? 'unknown';
        byStatus[status] = (byStatus[status] ?? 0) + 1;
        byStatusAmount[status] = (byStatusAmount[status] ?? 0.0) + (outflow['amount'] as num).toDouble();
      }

      final result = byStatus.entries.map((e) => {
        'status': e.key,
        'count': e.value,
        'amount': byStatusAmount[e.key] ?? 0.0,
      }).toList();

      _outflowsByStatus.assignAll(result);
    } catch (e) {
      print('Erreur rapport par statut: $e');
    }
  }

  /// Définir la plage de dates
  void setDateRange(DateTime start, DateTime end) {
    _dateRangeStart.value = start;
    _dateRangeEnd.value = end;
    chargerRapports();
  }

  /// Définir le statut sélectionné
  void setSelectedStatus(String? status) {
    _selectedStatus.value = status;
  }

  /// Définir la catégorie sélectionnée
  void setSelectedCategory(String? category) {
    _selectedCategory.value = category;
  }

  /// Exporter le rapport en PDF
  Future<void> exporterRapportPDF() async {
    try {
      _isLoading.value = true;
      final pdf = pw.Document();
      final totalAmount = (_periodStats.value?['total_amount'] as num?)?.toDouble() ?? 0;
      final totalCount = (_periodStats.value?['total_count'] as num?)?.toInt() ?? 0;
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (context) => [
            pw.Text('Rapport CashOut', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Text('Période: ${DateFormat('dd/MM/yyyy').format(_dateRangeStart.value!)} - ${DateFormat('dd/MM/yyyy').format(_dateRangeEnd.value!)}'),
            pw.SizedBox(height: 20),
            pw.Text('Montant total: ${totalAmount.toStringAsFixed(0)} FCFA'),
            pw.Text('Nombre de transactions: $totalCount'),
            pw.SizedBox(height: 16),
            pw.Table.fromTextArray(
              headers: const ['Catégorie', 'Montant', 'Part'],
              data: _categoryData.map((e) => [
                (e['name'] ?? 'Inconnue').toString(),
                '${((e['total_amount'] as num?)?.toDouble() ?? 0).toStringAsFixed(0)} FCFA',
                '${((e['percentage'] as num?)?.toDouble() ?? 0).toStringAsFixed(1)} %',
              ]).toList(),
            ),
          ],
        ),
      );
      await _pdfService.printPDF(await pdf.save());
      Get.snackbar('Succès', 'Rapport exporté');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible d\'exporter le rapport');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Réinitialiser les filtres
  void resetFilters() {
    _selectedStatus.value = null;
    _selectedCategory.value = null;
    _dateRangeStart.value = DateTime(DateTime.now().year, DateTime.now().month, 1);
    _dateRangeEnd.value = DateTime.now();
    chargerRapports();
  }

  /// Calculer le total validé
  double getTotalValidated() {
    return _outflowsByStatus
        .where((e) => e['status'] == 'validated')
        .fold<double>(0, (sum, e) => sum + (e['amount'] as num).toDouble());
  }

  /// Calculer le total en attente
  double getTotalPending() {
    return _outflowsByStatus
        .where((e) => e['status'] == 'pending')
        .fold<double>(0, (sum, e) => sum + (e['amount'] as num).toDouble());
  }

  /// Calculer le total rejeté
  double getTotalRejected() {
    return _outflowsByStatus
        .where((e) => e['status'] == 'rejected')
        .fold<double>(0, (sum, e) => sum + (e['amount'] as num).toDouble());
  }

  /// Obtenir le taux de validation
  double getValidationRate() {
    if (_outflowsByStatus.isEmpty) return 0;
    
    final totalCount = _outflowsByStatus
        .fold<int>(0, (sum, e) => sum + (e['count'] as int));
    
    final validatedCount = _outflowsByStatus
        .where((e) => e['status'] == 'validated')
        .fold<int>(0, (sum, e) => sum + (e['count'] as int));
    
    if (totalCount == 0) return 0;
    return validatedCount / totalCount;
  }
}
