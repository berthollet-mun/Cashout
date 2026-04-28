// ================================
// 📁 lib/controllers/category_controller.dart
// ================================

import 'package:get/get.dart';

import '../core/services/supabase_service.dart';
import '../data/models/category_model.dart';

class CategoryController extends GetxController {
  final SupabaseService _service = Get.find<SupabaseService>();

  // ── Variables observables ─────────────────────────
  final _categories  = <CategoryModel>[].obs;
  final _isLoading   = false.obs;
  final _errorMessage = ''.obs;

  // ── Getters ───────────────────────────────────────
  List<CategoryModel> get categories   => _categories;
  bool                get isLoading    => _isLoading.value;
  String              get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    chargerCategories();
  }

  // ── Charger les catégories ────────────────────────
  Future<void> chargerCategories() async {
    try {
      _isLoading.value = true;
      final data = await _service.getCategories();
      _categories.assignAll(data.map((e) => CategoryModel.fromJson(e)).toList());
    } catch (e) {
      _errorMessage.value = 'Impossible de charger les catégories';
    } finally {
      _isLoading.value = false;
    }
  }

  /// Trouver une catégorie par son ID
  CategoryModel? findById(String? id) {
    if (id == null) return null;
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}