import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';
import '../app/routes/app_routes.dart';
import '../data/models/profile_model.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final _supabase = SupabaseService.to;
  
  final Rxn<User> user = Rxn<User>();
  final Rxn<ProfileModel> profile = Rxn<ProfileModel>();
  final RxBool isLoading = false.obs;
  bool get isManagerOrAdmin => profile.value?.isManagerOrAdmin ?? false;

  @override
  void onInit() {
    super.onInit();
    user.value = _supabase.currentUser;
    if (user.value != null) {
      fetchProfile();
    }
    
    // Écouter les changements d'auth
    _supabase.authStateChanges.listen((data) {
      user.value = data.session?.user;
      if (user.value != null) {
        fetchProfile();
      } else {
        profile.value = null;
        Get.offAllNamed(AppRoutes.LOGIN);
      }
    });
  }

  Future<void> fetchProfile() async {
    if (user.value == null) return;
    try {
      final data = await _supabase.getProfile(user.value!.id);
      if (data != null) {
        profile.value = ProfileModel.fromJson(data);
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger le profil');
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      await _supabase.signIn(email: email, password: password);
      Get.offAllNamed(AppRoutes.DASHBOARD);
    } catch (e) {
      final raw = e.toString();
      final isConfigOrNetworkError =
          raw.contains('Failed to fetch') || raw.contains('ClientException');
      final msg = isConfigOrNetworkError
          ? 'Connexion impossible. Vérifiez votre URL/clé Supabase et votre réseau.'
          : raw;
      Get.snackbar('Erreur de connexion', msg);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(String email, String password, String fullName) async {
    try {
      isLoading.value = true;
      await _supabase.signUp(
        email: email, 
        password: password, 
        data: {'full_name': fullName}
      );
      Get.snackbar('Succès', 'Compte créé avec succès. Vérifiez vos emails.');
      Get.toNamed(AppRoutes.LOGIN);
    } catch (e) {
      Get.snackbar('Erreur d\'inscription', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _supabase.signOut();
  }
}
