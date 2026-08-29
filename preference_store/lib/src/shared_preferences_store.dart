import 'package:meta/meta.dart';
import 'package:preference_store/src/preference_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesStore implements PreferenceStore {
  final SharedPreferencesAsync _preferences;

  SharedPreferencesStore() : this._(SharedPreferencesAsync());

  @visibleForTesting
  SharedPreferencesStore.test(SharedPreferencesAsync preferences)
    : this._(preferences);

  SharedPreferencesStore._(this._preferences);

  @override
  Future<bool> containsKey(String key) {
    return _preferences.containsKey(key);
  }

  @override
  Future<Set<String>> getKeys({Set<String>? allowList}) {
    return _preferences.getKeys(allowList: allowList);
  }

  @override
  Future<Map<String, Object?>> getAll({Set<String>? allowList}) {
    return _preferences.getAll(allowList: allowList);
  }

  @override
  Future<bool?> getBool(String key) {
    return _preferences.getBool(key);
  }

  @override
  Future<int?> getInt(String key) {
    return _preferences.getInt(key);
  }

  @override
  Future<double?> getDouble(String key) {
    return _preferences.getDouble(key);
  }

  @override
  Future<String?> getString(String key) {
    return _preferences.getString(key);
  }

  @override
  Future<List<String>?> getStringList(String key) {
    return _preferences.getStringList(key);
  }

  @override
  Future<Set<String>?> getStringSet(String key) async {
    final list = await _preferences.getStringList(key);
    return list?.toSet();
  }

  @override
  Future<void> remove(String key) {
    return _preferences.remove(key);
  }

  @override
  Future<void> removeAll({Set<String>? allowList}) {
    return _preferences.clear(allowList: allowList);
  }

  @override
  Future<void> setBool(String key, bool value) {
    return _preferences.setBool(key, value);
  }

  @override
  Future<void> setInt(String key, int value) {
    return _preferences.setInt(key, value);
  }

  @override
  Future<void> setDouble(String key, double value) {
    return _preferences.setDouble(key, value);
  }

  @override
  Future<void> setString(String key, String value) {
    return _preferences.setString(key, value);
  }

  @override
  Future<void> setStringList(String key, List<String> value) {
    return _preferences.setStringList(key, value);
  }
}
