import 'package:checkers_app/core/storage/storage_exception.dart';
import 'package:checkers_app/features/statistics/data/datasources/local/stats_local_data_source.dart';
import 'package:checkers_app/features/statistics/data/dto/game_stats_dto.dart';
import 'package:checkers_app/features/statistics/data/mappers/game_stats_mapper.dart';
import 'package:checkers_app/features/statistics/domain/statistics_domain.dart';
import 'package:json_annotation/json_annotation.dart';

class StatsRepositoryImpl implements StatsRepository {
  const StatsRepositoryImpl(this._local);

  final StatsLocalDataSource _local;

  @override
  Future<GameStats> load() async {
    final GameStatsDto? dto;
    try {
      dto = await _local.read();
    } on StorageException catch (_, st) {
      Error.throwWithStackTrace(const StatsStorageException(), st);
    } on FormatException catch (_, st) {
      Error.throwWithStackTrace(const StatsCorruptedException(), st);
    } on CheckedFromJsonException catch (_, st) {
      Error.throwWithStackTrace(const StatsCorruptedException(), st);
    }
    return dto?.toDomain() ?? GameStats.empty;
  }

  @override
  Future<void> save(GameStats stats) async {
    try {
      await _local.write(stats.toDto());
    } on StorageException catch (_, st) {
      Error.throwWithStackTrace(const StatsStorageException(), st);
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _local.delete();
    } on StorageException catch (_, st) {
      Error.throwWithStackTrace(const StatsStorageException(), st);
    }
  }
}
