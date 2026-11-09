import 'package:checkers_app/core/analytics/track_event.dart';
import 'package:checkers_app/core/storage/key_value_storage.dart';
import 'package:checkers_app/features/shared/game_results/game_result_recorder.dart';
import 'package:checkers_app/features/statistics/data/datasources/local/stats_local_data_source.dart';
import 'package:checkers_app/features/statistics/data/repositories/stats_repository_impl.dart';
import 'package:checkers_app/features/statistics/domain/statistics_domain.dart';
import 'package:checkers_app/features/statistics/presentation/bloc/stats/stats_bloc.dart';
import 'package:injectable/injectable.dart';

/// Statistics feature: storage, use cases, the bloc and the core
/// [GameResultRecorder] port it implements.
@module
abstract class StatisticsModule {
  @lazySingleton
  StatsLocalDataSource statsLocalDataSource(KeyValueStorage storage) =>
      StatsLocalDataSource(storage);

  @lazySingleton
  StatsRepository statsRepository(StatsLocalDataSource local) =>
      StatsRepositoryImpl(local);

  @lazySingleton
  GetGameStats getGameStats(StatsRepository repository) =>
      GetGameStats(repository);

  @lazySingleton
  ResetGameStats resetGameStats(StatsRepository repository) =>
      ResetGameStats(repository);

  @lazySingleton
  GameResultRecorder gameResultRecorder(StatsRepository repository) =>
      RecordGameResult(repository);

  /// Blocs are factories: a new one for every statistics screen.
  @injectable
  StatsBloc statsBloc(
    GetGameStats getGameStats,
    ResetGameStats resetGameStats,
    TrackEvent trackEvent,
  ) => StatsBloc(getGameStats, resetGameStats, trackEvent);
}
