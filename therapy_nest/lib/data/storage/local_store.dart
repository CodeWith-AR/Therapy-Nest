import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences wrapper for general app settings.
class LocalStore {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ── Generic getters/setters ──────────────────────────────────────

  Future<String?> getString(String key) async {
    final prefs = await _instance;
    return prefs.getString(key);
  }

  Future<bool> setString(String key, String value) async {
    final prefs = await _instance;
    return prefs.setString(key, value);
  }

  Future<bool?> getBool(String key) async {
    final prefs = await _instance;
    return prefs.getBool(key);
  }

  Future<bool> setBool(String key, bool value) async {
    final prefs = await _instance;
    return prefs.setBool(key, value);
  }

  Future<int?> getInt(String key) async {
    final prefs = await _instance;
    return prefs.getInt(key);
  }

  Future<bool> setInt(String key, int value) async {
    final prefs = await _instance;
    return prefs.setInt(key, value);
  }

  Future<bool> remove(String key) async {
    final prefs = await _instance;
    return prefs.remove(key);
  }

  // ── App-specific keys ────────────────────────────────────────────

  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyLastUserId = 'last_user_id';

  Future<bool> get isOnboardingComplete async =>
      (await getBool(_keyOnboardingComplete)) ?? false;

  Future<void> setOnboardingComplete(bool value) async =>
      await setBool(_keyOnboardingComplete, value);

  Future<String?> get lastUserId async => getString(_keyLastUserId);

  Future<void> setLastUserId(String id) async =>
      await setString(_keyLastUserId, id);
}
