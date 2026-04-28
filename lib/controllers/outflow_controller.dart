import 'package:get/get.dart';
import '../core/services/supabase_service.dart';
import '../data/models/outflow_model.dart';
import '../data/models/category_model.dart';
import 'auth_controller.dart';

class OutflowController extends GetxController {
  final _supabase = SupabaseService.to;
  
  final RxList<OutflowModel> outflows = <OutflowModel>[].obs;
  final RxList<OutflowModel> _allOutflows = <OutflowModel>[].obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchOutflows();
  }

  Future<void> fetchCategories() async {
    try {
      final data = await _supabase.getCategories();
      categories.assignAll(data.map((e) => CategoryModel.fromJson(e)).toList());
    } catch (e) {
      print('Erreur categories: $e');
    }
  }

  Future<void> fetchOutflows() async {
    try {
      isLoading.value = true;
      final data = await _supabase.getOutflows();
      final list = data.map((e) => OutflowModel.fromJson(e)).toList();
      _allOutflows.assignAll(list);
      outflows.assignAll(list);
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les sorties');
    } finally {
      isLoading.value = false;
    }
  }

  void searchOutflows(String query) {
    if (query.isEmpty) {
      outflows.assignAll(_allOutflows);
    } else {
      final filtered = _allOutflows.where((o) =>
          o.description.toLowerCase().contains(query.toLowerCase()) ||
          o.recipient.toLowerCase().contains(query.toLowerCase()) ||
          (o.receiptNo?.toLowerCase().contains(query.toLowerCase()) ?? false)).toList();
      outflows.assignAll(filtered);
    }
  }

  Future<void> createOutflow({
    required double amount,
    required String description,
    required String categoryId,
    required String recipient,
    String? recipientPhone,
    String? recipientEmail,
    String paymentMethod = 'cash',
    String? notes,
  }) async {
    try {
      isLoading.value = true;
      final userId = AuthController.to.user.value?.id;
      if (userId == null) return;

      final data = {
        'amount': amount,
        'description': description,
        'category_id': categoryId,
        'user_id': userId,
        'recipient': recipient,
        'recipient_phone': recipientPhone,
        'recipient_email': recipientEmail,
        'payment_method': paymentMethod,
        'notes': notes,
        'status': 'pending',
        'outflow_date': DateTime.now().toIso8601String().split('T')[0],
      };

      await _supabase.createOutflow(data);
      await fetchOutflows();
      Get.back();
      Get.snackbar('Succès', 'Sortie de caisse enregistrée');
    } catch (e) {
      Get.snackbar('Erreur', 'Échec de la création : $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStatus(String id, String status, {String? reason, String? comment}) async {
    try {
      isLoading.value = true;
      final userId = AuthController.to.user.value?.id;
      if (userId == null) return;

      final result = await _supabase.updateOutflowStatusRpc(
        outflowId: id,
        newStatus: status,
        userId: userId,
        reason: reason,
        comment: comment ?? 'Mise à jour via l\'application',
      );

      if (result['success'] == true) {
        await fetchOutflows();
        Get.snackbar('Succès', result['message'] ?? 'Statut mis à jour');
        if (Get.isDialogOpen ?? false) Get.back();
      } else {
        Get.snackbar('Erreur', result['message'] ?? 'Échec de la mise à jour');
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Échec de la mise à jour : $e');
    } finally {
      isLoading.value = false;
    }
  }
}
