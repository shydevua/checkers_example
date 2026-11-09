import 'dart:convert';

import 'package:checkers_app/core/storage/key_value_storage.dart';
import 'package:checkers_app/core/storage/storage_exception.dart';
import 'package:checkers_app/features/statistics/data/dto/game_stats_dto.dart';
import 'package:json_annotation/json_annotation.dart';

/// Stores statistics as JSON in the key-value storage.
class StatsLocalDataSource {
  const StatsLocalDataSource(this._storage);

  final KeyValueStorage _storage;

  static const storageKey = 'checkers.stats.v1';

  /// Returns the stored statistics, or `null` if nothing is stored.
  ///
  /// Throws [StorageException] if storage fails, [FormatException] if the
  /// payload is not a JSON object or [CheckedFromJsonException] if it does
  /// not match the schema.
  Future<GameStatsDto?> read() async {
    final raw = await _storage.read(storageKey);
    if (raw == null) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Stats payload is not a JSON object');
    }
    return GameStatsDto.fromJson(decoded);
  }

  /// Throws [StorageException] if storage fails.
  Future<void> write(GameStatsDto stats) async =>
      _storage.write(storageKey, jsonEncode(stats.toJson()));

  /// Throws [StorageException] if storage fails.
  Future<void> delete() async => _storage.delete(storageKey);
}
