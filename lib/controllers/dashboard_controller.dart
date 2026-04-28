// ================================
// 📁 lib/controllers/dashboard_controller.dart
// ================================

import 'package:get/get.dart';

import '../core/services/supabase_service.dart';
import '../data/models/dashboard_model.dart';
import '../data/models/outflow_model.dart';

class DashboardController extends GetxController {
  final SupabaseService _service = Get.find<SupabaseService>();

  // ── Variables observables ─────────────────────────
  final _dashboard          = Rxn<DashboardModel>();
  final _recentOutflows     = <OutflowModel>[].obs;
  final _categorySummary    = <Map<String, dynamic>>[].obs;
  final _isLoading          = false.obs;
  final _errorMessage       = ''.obs;

  // ── Getters ───────────────────────────────────────
  DashboardModel?           get dashboard       => _dashboard.value;
  List<OutflowModel>        get recentOutflows  => _recentOutflows;
  List<Map<String,dynamic>> get categorySummary => _categorySummary;
  bool                      get isLoading       => _isLoading.value;
  String                    get errorMessage    => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    chargerDashboard();
  }

  Future<void> chargerDashboard() async {
    try {
      _isLoading.value    = true;
      _errorMessage.value = '';

      // Chargement en parallèle
      final results = await Future.wait([
        _service.getDashboardData(),
        _service.getOutflows(limit: 5),
        _service.getCategorySummary(),
      ]);

      // Dashboard
      final dashData = results[0] as Map<String, dynamic>?;
      if (dashData != null) {
        _dashboard.value = DashboardModel.fromJson(dashData);
      }

      // Sorties récentes
      final recentData = results[1] as List<Map<String, dynamic>>;
      _recentOutflows.assignAll(recentData.map((e) => OutflowModel.fromJson(e)).toList());

      // Résumé catégories
      final cats = results[2] as List<Map<String, dynamic>>;
      _categorySummary.assignAll(cats);
    } catch (e) {
      _errorMessage.value = 'Impossible de charger le dashboard: $e';
      Get.log('Dashboard error: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Rafraîchir les données
  Future<void> rafraichir() => chargerDashboard();
}