import 'package:checkers_app/app/di/injection.dart';
import 'package:checkers_app/core/analytics/analytics.dart';
import 'package:checkers_app/core/analytics/noop_analytics.dart';
import 'package:checkers_app/core/analytics/track_event.dart';
import 'package:checkers_app/core/monitoring/error_reporter.dart';
import 'package:checkers_app/core/monitoring/noop_error_reporter.dart';
import 'package:checkers_app/core/usecases/use_case.dart';
import 'package:checkers_app/features/game/domain/game_domain.dart';
import 'package:checkers_app/features/game/presentation/bloc/game/game_bloc.dart';
import 'package:checkers_app/features/shared/game_results/difficulty.dart';
import 'package:checkers_app/features/shared/game_results/game_outcome.dart';
import 'package:checkers_app/features/shared/game_results/game_result.dart';
import 'package:checkers_app/features/shared/game_results/game_result_recorder.dart';
import 'package:checkers_app/features/shared/game_results/level_stats.dart';
import 'package:checkers_app/features/statistics/domain/statistics_domain.dart';
import 'package:checkers_app/features/statistics/presentation/bloc/stats/stats_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:injectable/injectable.dart' show Environment;
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  tearDown(getIt.reset);

  test('composition root resolves every use case and port', () async {
    await configureDependencies(Environment.dev);
    expect(getIt<StatsRepository>(), isNotNull);
    expect(getIt<StartNewGame>(), isNotNull);
    expect(getIt<SelectSquare>(), isNotNull);
    expect(getIt<MakeMove>(), isNotNull);
    expect(getIt<ComputeAiMove>(), isNotNull);
    expect(getIt<SaveGameResult>(), isNotNull);
    expect(getIt<GetGameStats>(), isNotNull);
    expect(getIt<ResetGameStats>(), isNotNull);
    expect(getIt<TrackEvent>(), isNotNull);
  });

  test('blocs are factories: a new instance per screen', () async {
    await configureDependencies(Environment.dev);
    final game = getIt<GameBloc>();
    final stats = getIt<StatsBloc>();
    addTearDown(game.close);
    addTearDown(stats.close);
    expect(getIt<GameBloc>(), isNot(same(game)));
    expect(getIt<StatsBloc>(), isNot(same(stats)));
  });

  test('ports are bound to their current implementations', () async {
    await configureDependencies(Environment.dev);
    expect(getIt<GameResultRecorder>(), isA<RecordGameResult>());
    expect(getIt<Analytics>(), isA<NoopAnalytics>());
    expect(getIt<ErrorReporter>(), isA<NoopErrorReporter>());
  });

  test('a finished game reaches statistics through the core port', () async {
    await configureDependencies(Environment.dev);
    final totals = await getIt<SaveGameResult>()(
      const GameResult(
        difficulty: Difficulty.medium,
        outcome: GameOutcome.draw,
      ),
    );
    expect(totals, LevelStats(draws: 1));
    expect(
      await getIt<GetGameStats>()(const NoParams()),
      GameStats(medium: LevelStats(draws: 1)),
    );
  });
}
