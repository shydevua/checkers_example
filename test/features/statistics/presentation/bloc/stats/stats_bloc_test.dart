import 'package:bloc_test/bloc_test.dart';
import 'package:checkers_app/core/analytics/analytics_event.dart';
import 'package:checkers_app/core/analytics/track_event.dart';
import 'package:checkers_app/core/usecases/use_case.dart';
import 'package:checkers_app/features/shared/game_results/level_stats.dart';
import 'package:checkers_app/features/statistics/domain/statistics_domain.dart';
import 'package:checkers_app/features/statistics/presentation/bloc/stats/stats_bloc.dart';
import 'package:checkers_app/features/statistics/presentation/bloc/stats/stats_event.dart';
import 'package:checkers_app/features/statistics/presentation/bloc/stats/stats_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetGameStats extends Mock implements GetGameStats {}

class _MockResetGameStats extends Mock implements ResetGameStats {}

class _MockTrackEvent extends Mock implements TrackEvent {}

void main() {
  late _MockGetGameStats getGameStats;
  late _MockResetGameStats resetGameStats;
  late _MockTrackEvent trackEvent;
  final stats = GameStats(medium: LevelStats(wins: 3));

  setUpAll(() => registerFallbackValue(AnalyticsEvent('fallback')));

  setUp(() {
    getGameStats = _MockGetGameStats();
    resetGameStats = _MockResetGameStats();
    trackEvent = _MockTrackEvent();
    when(() => trackEvent(any())).thenAnswer((_) async {});
  });

  StatsBloc build() => StatsBloc(getGameStats, resetGameStats, trackEvent);

  test('initial state -> StatsInitial', () {
    expect(build().state, const StatsInitial());
  });

  group('StatsRequested', () {
    blocTest<StatsBloc, StatsState>(
      'success -> [InProgress, Loaded]',
      setUp: () => when(
        () => getGameStats(const NoParams()),
      ).thenAnswer((_) async => stats),
      build: build,
      act: (bloc) => bloc.add(const StatsRequested()),
      expect: () => [const StatsLoadInProgress(), StatsLoaded(stats)],
      verify: (_) {
        verify(() => getGameStats(const NoParams())).called(1);
        verifyZeroInteractions(trackEvent);
      },
    );

    blocTest<StatsBloc, StatsState>(
      'StatsCorruptedException -> [InProgress, Failure]',
      setUp: () => when(
        () => getGameStats(const NoParams()),
      ).thenThrow(const StatsCorruptedException()),
      build: build,
      act: (bloc) => bloc.add(const StatsRequested()),
      expect: () => [
        const StatsLoadInProgress(),
        const StatsFailure(StatsCorruptedException()),
      ],
    );

    blocTest<StatsBloc, StatsState>(
      'unexpected error -> not swallowed',
      setUp: () => when(
        () => getGameStats(const NoParams()),
      ).thenThrow(StateError('bug')),
      build: build,
      act: (bloc) => bloc.add(const StatsRequested()),
      expect: () => [const StatsLoadInProgress()],
      errors: () => [isA<StateError>()],
    );
  });

  group('StatsResetRequested', () {
    blocTest<StatsBloc, StatsState>(
      'success -> [InProgress, Loaded(empty)]',
      setUp: () => when(
        () => resetGameStats(const NoParams()),
      ).thenAnswer((_) async => GameStats.empty),
      build: build,
      seed: () => StatsLoaded(stats),
      act: (bloc) => bloc.add(const StatsResetRequested()),
      expect: () => [
        const StatsLoadInProgress(),
        const StatsLoaded(GameStats.empty),
      ],
      verify: (_) {
        verifyZeroInteractions(getGameStats);
        verify(() => trackEvent(AnalyticsEvent('stats_reset'))).called(1);
      },
    );

    blocTest<StatsBloc, StatsState>(
      'StatsStorageException -> [InProgress, Failure]',
      setUp: () => when(
        () => resetGameStats(const NoParams()),
      ).thenThrow(const StatsStorageException()),
      build: build,
      act: (bloc) => bloc.add(const StatsResetRequested()),
      expect: () => [
        const StatsLoadInProgress(),
        const StatsFailure(StatsStorageException()),
      ],
      verify: (_) => verifyZeroInteractions(trackEvent),
    );

    blocTest<StatsBloc, StatsState>(
      'unexpected error -> not swallowed',
      setUp: () => when(
        () => resetGameStats(const NoParams()),
      ).thenThrow(StateError('bug')),
      build: build,
      act: (bloc) => bloc.add(const StatsResetRequested()),
      expect: () => [const StatsLoadInProgress()],
      errors: () => [isA<StateError>()],
    );
  });
}
