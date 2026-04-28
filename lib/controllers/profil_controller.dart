import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../core/services/storage_service.dart';
import '../core/services/supabase_service.dart';
import '../data/models/profil_model.dart';
import 'auth_controller.dart';
import 'theme_controller.dart';

class ProfilController extends GetxController {
  final _supabase = SupabaseService.to;
  final _storage = StorageService.to;

  final profil = Rxn<ProfilModel>();
  final isLoading = false.obs;
  final isSaving = false.obs;
  final showCurrentPassword = false.obs;
  final showNewPassword = false.obs;
  final showConfirmPassword = false.obs;

  final notificationsEnabled = true.obs;
  final selectedLanguage = 'fr'.obs;
  final fontScale = 1.0.obs;

  @override
  void onInit() {
    super.onInit();
    notificationsEnabled.value = _storage.notificationsEnabled;
    selectedLanguage.value = _storage.preferredLanguage;
    fontScale.value = _storage.fontScale;
    loadProfil();
  }

  Future<void> loadProfil() async {
    try {
      isLoading.value = true;
      final userId = AuthController.to.user.value?.id;
      if (userId == null) return;
      final data = await _supabase.getProfile(userId);
      if (data != null) {
        final model = ProfilModel.fromJson(data).copyWith(
          notificationsActives: notificationsEnabled.value,
          langue: selectedLanguage.value,
          taillePolice: fontScale.value,
        );
        profil.value = model;
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger le profil: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveProfil(ProfilModel updated) async {
    try {
      isSaving.value = true;
      final userId = AuthController.to.user.value?.id;
      if (userId == null) return;

      final payload = updated.toJson()
        ..remove('id')
        ..remove('email')
        ..remove('created_at');
      final result = await _supabase.updateProfile(userId, payload);
      profil.value = ProfilModel.fromJson(result);
      Get.snackbar('Succès', 'Profil mis à jour');
    } catch (e) {
      Get.snackbar('Erreur', 'Echec de la sauvegarde: $e');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> pickAndUploadAvatar(ImageSource source) async {
    try {
      isSaving.value = true;
      final userId = AuthController.to.user.value?.id;
      if (userId == null) return;

      final picker = ImagePicker();
      final file = await picker.pickImage(source: source, imageQuality: 80);
      if (file == null) return;

      final bytes = await file.readAsBytes();
      final ext = file.name.split('.').last.toLowerCase();
      final publicUrl = await _supabase.uploadAvatar(
        userId: userId,
        bytes: bytes,
        extension: ext.isEmpty ? 'jpg' : ext,
      );
      await _supabase.updateProfile(userId, {'avatar_url': publicUrl});
      await loadProfil();
    } catch (e) {
      Get.snackbar('Erreur', 'Upload avatar impossible: $e');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword != confirmPassword) {
      Get.snackbar('Erreur', 'La confirmation ne correspond pas');
      return;
    }
    if (newPassword.length < 8) {
      Get.snackbar('Erreur', 'Le mot de passe doit contenir au moins 8 caractères');
      return;
    }
    try {
      isSaving.value = true;
      await _supabase.updatePassword(newPassword);
      Get.snackbar('Succès', 'Mot de passe modifié');
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de changer le mot de passe: $e');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> setDarkMode(bool value) async {
    final themeController = Get.find<ThemeController>();
    if (themeController.isDarkMode.value != value) {
      themeController.toggleTheme();
    }
  }

  Future<void> setLanguage(String value) async {
    selectedLanguage.value = value;
    await _storage.savePreferredLanguage(value);
  }

  Future<void> setNotifications(bool value) async {
    notificationsEnabled.value = value;
    await _storage.saveNotificationsEnabled(value);
  }

  Future<void> setFontScale(double value) async {
    fontScale.value = value;
    await _storage.saveFontScale(value);
  }

  int get totalSortiesCreees {
    // Valeur par défaut. Peut être reliée à une table de stats ultérieurement.
    return 0;
  }

  double get totalMontantsGeres {
    return 0;
  }
}
