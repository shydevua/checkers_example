import 'package:checkers_app/core/storage/key_value_storage.dart';
import 'package:checkers_app/core/storage/storage_exception.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [KeyValueStorage] backed by the platform's shared preferences.
class SharedPreferencesStorage implements KeyValueStorage {
  const SharedPreferencesStorage(this._preferences);

  final SharedPreferencesAsync _preferences;

  /// Throws [StorageException] if the platform storage fails.
  @override
  Future<String?> read(String key) async {
    try {
      return await _preferences.getString(key);
    } on PlatformException catch (e, st) {
      Error.throwWithStackTrace(StorageException(_describe(e)), st);
    }
  }

  /// Throws [StorageException] if the platform storage fails.
  @override
  Future<void> write(String key, String value) async {
    try {
      await _preferences.setString(key, value);
    } on PlatformException catch (e, st) {
      Error.throwWithStackTrace(StorageException(_describe(e)), st);
    }
  }

  /// Throws [StorageException] if the platform storage fails.
  @override
  Future<void> delete(String key) async {
    try {
      await _preferences.remove(key);
    } on PlatformException catch (e, st) {
      Error.throwWithStackTrace(StorageException(_describe(e)), st);
    }
  }

  static String _describe(PlatformException e) => '${e.code}: ${e.message}';
}
