import 'package:get_storage/get_storage.dart';

class StorageService {
  static final GetStorage _box = GetStorage();

  // Keys
  static const String _keyToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUser = 'user_data';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyLanguage = 'language';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyFcmToken = 'fcm_token';
  static const String _keySelectedAddress = 'selected_address';

  // Initialize
  static Future<void> init() async {
    await GetStorage.init();
  }

  // Auth Token
  static String? get token => _box.read(_keyToken);
  static Future<void> setToken(String token) async {
    await _box.write(_keyToken, token);
  }

  static Future<void> removeToken() async {
    await _box.remove(_keyToken);
  }

  // Refresh Token
  static String? get refreshToken => _box.read(_keyRefreshToken);
  static Future<void> setRefreshToken(String token) async {
    await _box.write(_keyRefreshToken, token);
  }

  // User Data
  static Map<String, dynamic>? get userData => _box.read(_keyUser);
  static Future<void> setUserData(Map<String, dynamic> data) async {
    await _box.write(_keyUser, data);
  }

  static Future<void> removeUserData() async {
    await _box.remove(_keyUser);
  }

  // Is Logged In
  static bool get isLoggedIn => _box.read(_keyIsLoggedIn) ?? false;
  static Future<void> setIsLoggedIn(bool value) async {
    await _box.write(_keyIsLoggedIn, value);
  }

  // Language
  static String get language => _box.read(_keyLanguage) ?? 'lo';
  static Future<void> setLanguage(String lang) async {
    await _box.write(_keyLanguage, lang);
  }

  // Theme Mode
  static String get themeMode => _box.read(_keyThemeMode) ?? 'light';
  static Future<void> setThemeMode(String mode) async {
    await _box.write(_keyThemeMode, mode);
  }

  // FCM Token
  static String? get fcmToken => _box.read(_keyFcmToken);
  static Future<void> setFcmToken(String token) async {
    await _box.write(_keyFcmToken, token);
  }

  // Selected Address
  static Map<String, dynamic>? get selectedAddress => _box.read(_keySelectedAddress);
  static Future<void> setSelectedAddress(Map<String, dynamic> address) async {
    await _box.write(_keySelectedAddress, address);
  }

  // Clear All
  static Future<void> clearAll() async {
    await _box.erase();
  }

  // Clear Auth Data
  static Future<void> clearAuthData() async {
    await removeToken();
    await removeUserData();
    await setIsLoggedIn(false);
  }
}
