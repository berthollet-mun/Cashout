import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class StorageService extends GetxService {
  static StorageService get to => Get.find();
  late SharedPreferences _prefs;

  static Future<StorageService> init() async {
    final service = StorageService();
    service._prefs = await SharedPreferences.getInstance();
    return service;
  }

  // --- THEME ---
  Future<void> saveThemeMode(bool isDarkMode) async {
    await _prefs.setBool('isDarkMode', isDarkMode);
  }

  bool get isDarkMode => _prefs.getBool('isDarkMode') ?? false;

  // --- AUTH ---
  Future<void> saveUserSession(String token) async {
    await _prefs.setString('auth_token', token);
  }

  String? get userToken => _prefs.getString('auth_token');

  Future<void> clearSession() async {
    await _prefs.remove('auth_token');
  }

  // --- PROFIL / PARAMETRES ---
  Future<void> savePreferredLanguage(String value) async {
    await _prefs.setString('preferred_language', value);
  }

  String get preferredLanguage => _prefs.getString('preferred_language') ?? 'fr';

  Future<void> saveFontScale(double value) async {
    await _prefs.setDouble('font_scale', value);
  }

  double get fontScale => _prefs.getDouble('font_scale') ?? 1.0;

  Future<void> saveNotificationsEnabled(bool value) async {
    await _prefs.setBool('notifications_enabled', value);
  }

  bool get notificationsEnabled => _prefs.getBool('notifications_enabled') ?? true;

  // --- GENERAL ---
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
