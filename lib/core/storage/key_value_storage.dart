import 'package:checkers_app/core/storage/storage_exception.dart';

/// Persistent string storage used by data sources.
abstract interface class KeyValueStorage {
  /// Returns the value stored under [key], or `null` if there is none.
  ///
  /// Throws [StorageException] if the storage cannot be read.
  Future<String?> read(String key);

  /// Stores [value] under [key].
  ///
  /// Throws [StorageException] if the storage cannot be written.
  Future<void> write(String key, String value);

  /// Removes the value stored under [key].
  ///
  /// Throws [StorageException] if the storage cannot be written.
  Future<void> delete(String key);
}
