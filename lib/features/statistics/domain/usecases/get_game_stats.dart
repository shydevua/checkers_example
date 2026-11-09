import 'package:checkers_app/core/usecases/use_case.dart';
import 'package:checkers_app/features/statistics/domain/entities/game_stats.dart';
import 'package:checkers_app/features/statistics/domain/exceptions/stats_exception.dart';
import 'package:checkers_app/features/statistics/domain/repositories/stats_repository.dart';

class GetGameStats implements UseCase<GameStats, NoParams> {
  const GetGameStats(this._repository);

  final StatsRepository _repository;

  /// Throws [StatsStorageException] or [StatsCorruptedException] from
  /// [StatsRepository.load].
  @override
  Future<GameStats> call(NoParams params) async => _repository.load();
}
