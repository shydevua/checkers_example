import 'package:checkers_app/core/usecases/use_case.dart';
import 'package:checkers_app/features/statistics/domain/entities/game_stats.dart';
import 'package:checkers_app/features/statistics/domain/exceptions/stats_exception.dart';
import 'package:checkers_app/features/statistics/domain/repositories/stats_repository.dart';

class ResetGameStats implements UseCase<GameStats, NoParams> {
  const ResetGameStats(this._repository);

  final StatsRepository _repository;

  /// Throws [StatsStorageException] from [StatsRepository.clear].
  @override
  Future<GameStats> call(NoParams params) async {
    await _repository.clear();
    return GameStats.empty;
  }
}
