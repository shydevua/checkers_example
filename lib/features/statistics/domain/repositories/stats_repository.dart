import 'package:checkers_app/features/statistics/domain/entities/game_stats.dart';
import 'package:checkers_app/features/statistics/domain/exceptions/stats_exception.dart';

abstract interface class StatsRepository {
  /// Returns the stored statistics, or [GameStats.empty] if none are stored.
  ///
  /// Throws [StatsStorageException] if storage cannot be read or
  /// [StatsCorruptedException] if the stored data cannot be understood.
  Future<GameStats> load();

  /// Throws [StatsStorageException] if storage cannot be written.
  Future<void> save(GameStats stats);

  /// Removes all stored statistics.
  ///
  /// Throws [StatsStorageException] if storage cannot be written.
  Future<void> clear();
}
