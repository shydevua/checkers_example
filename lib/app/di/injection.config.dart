// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:checkers_app/app/di/modules/core_module.dart' as _i524;
import 'package:checkers_app/app/di/modules/game_module.dart' as _i816;
import 'package:checkers_app/app/di/modules/statistics_module.dart' as _i449;
import 'package:checkers_app/core/analytics/analytics.dart' as _i148;
import 'package:checkers_app/core/analytics/track_event.dart' as _i247;
import 'package:checkers_app/core/monitoring/error_reporter.dart' as _i475;
import 'package:checkers_app/core/storage/key_value_storage.dart' as _i658;
import 'package:checkers_app/features/game/domain/game_domain.dart' as _i89;
import 'package:checkers_app/features/game/presentation/bloc/game/ai_move_delay.dart'
    as _i779;
import 'package:checkers_app/features/game/presentation/bloc/game/game_bloc.dart'
    as _i689;
import 'package:checkers_app/features/shared/game_results/game_result_recorder.dart'
    as _i583;
import 'package:checkers_app/features/statistics/data/datasources/local/stats_local_data_source.dart'
    as _i414;
import 'package:checkers_app/features/statistics/domain/statistics_domain.dart'
    as _i314;
import 'package:checkers_app/features/statistics/presentation/bloc/stats/stats_bloc.dart'
    as _i299;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final coreModule = _$CoreModule();
    final gameModule = _$GameModule();
    final statisticsModule = _$StatisticsModule();
    gh.lazySingleton<_i460.SharedPreferencesAsync>(
      () => coreModule.sharedPreferences,
    );
    gh.lazySingleton<_i148.Analytics>(() => coreModule.analytics);
    gh.lazySingleton<_i475.ErrorReporter>(() => coreModule.errorReporter);
    gh.lazySingleton<_i89.CheckersRules>(() => gameModule.rules);
    gh.lazySingleton<_i89.AiEngine>(() => gameModule.aiEngine);
    gh.lazySingleton<_i779.AiMoveDelay>(() => gameModule.aiMoveDelay);
    gh.lazySingleton<_i89.SelectSquare>(() => gameModule.selectSquare);
    gh.lazySingleton<_i89.StartNewGame>(
      () => gameModule.startNewGame(gh<_i89.CheckersRules>()),
    );
    gh.lazySingleton<_i89.MakeMove>(
      () => gameModule.makeMove(gh<_i89.CheckersRules>()),
    );
    gh.lazySingleton<_i247.TrackEvent>(
      () => coreModule.trackEvent(gh<_i148.Analytics>()),
    );
    gh.lazySingleton<_i89.ComputeAiMove>(
      () => gameModule.computeAiMove(gh<_i89.AiEngine>()),
    );
    gh.lazySingleton<_i658.KeyValueStorage>(
      () => coreModule.storage(gh<_i460.SharedPreferencesAsync>()),
    );
    gh.lazySingleton<_i414.StatsLocalDataSource>(
      () => statisticsModule.statsLocalDataSource(gh<_i658.KeyValueStorage>()),
    );
    gh.lazySingleton<_i314.StatsRepository>(
      () => statisticsModule.statsRepository(gh<_i414.StatsLocalDataSource>()),
    );
    gh.lazySingleton<_i314.GetGameStats>(
      () => statisticsModule.getGameStats(gh<_i314.StatsRepository>()),
    );
    gh.lazySingleton<_i314.ResetGameStats>(
      () => statisticsModule.resetGameStats(gh<_i314.StatsRepository>()),
    );
    gh.lazySingleton<_i583.GameResultRecorder>(
      () => statisticsModule.gameResultRecorder(gh<_i314.StatsRepository>()),
    );
    gh.lazySingleton<_i89.SaveGameResult>(
      () => gameModule.saveGameResult(gh<_i583.GameResultRecorder>()),
    );
    gh.factory<_i299.StatsBloc>(
      () => statisticsModule.statsBloc(
        gh<_i314.GetGameStats>(),
        gh<_i314.ResetGameStats>(),
        gh<_i247.TrackEvent>(),
      ),
    );
    gh.factory<_i689.GameBloc>(
      () => gameModule.gameBloc(
        gh<_i89.StartNewGame>(),
        gh<_i89.SelectSquare>(),
        gh<_i89.MakeMove>(),
        gh<_i89.ComputeAiMove>(),
        gh<_i89.SaveGameResult>(),
        gh<_i247.TrackEvent>(),
        gh<_i779.AiMoveDelay>(),
      ),
    );
    return this;
  }
}

class _$CoreModule extends _i524.CoreModule {}

class _$GameModule extends _i816.GameModule {}

class _$StatisticsModule extends _i449.StatisticsModule {}
