import 'package:checkers_app/features/shared/game_results/difficulty.dart';
import 'package:checkers_app/features/shared/game_results/game_outcome.dart';
import 'package:checkers_app/features/shared/game_results/game_result.dart';
import 'package:checkers_app/features/shared/game_results/game_result_exception.dart';
import 'package:checkers_app/features/shared/game_results/game_result_recorder.dart';
import 'package:checkers_app/features/shared/game_results/level_stats.dart';
import 'package:checkers_app/features/statistics/domain/statistics_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockStatsRepository extends Mock implements StatsRepository {}

void main() {
  late _MockStatsRepository repository;
  late RecordGameResult sut;
  final stored = GameStats(
    easy: LevelStats(wins: 4),
    hard: LevelStats(wins: 1, losses: 1),
  );
  final updated = GameStats(
    easy: LevelStats(wins: 4),
    hard: LevelStats(wins: 2, losses: 1),
  );
  const result = GameResult(
    difficulty: Difficulty.hard,
    outcome: GameOutcome.win,
  );

  setUpAll(() => registerFallbackValue(GameStats.empty));

  setUp(() {
    repository = _MockStatsRepository();
    sut = RecordGameResult(repository);
  });

  test('is the GameResultRecorder port', () {
    expect(sut, isA<GameResultRecorder>());
  });

  test('loads, adds, saves and returns the totals of that level', () async {
    when(() => repository.load()).thenAnswer((_) async => stored);
    when(() => repository.save(updated)).thenAnswer((_) async {});
    expect(await sut.record(result), LevelStats(wins: 2, losses: 1));
    verifyInOrder([() => repository.load(), () => repository.save(updated)]);
    verifyNoMoreInteractions(repository);
  });

  test(
    'corrupted stats -> GameResultNotSavedException, nothing saved',
    () async {
      when(() => repository.load()).thenThrow(const StatsCorruptedException());
      await expectLater(
        sut.record(result),
        throwsA(const GameResultNotSavedException()),
      );
      verifyNever(() => repository.save(any()));
    },
  );

  test('save fails -> GameResultNotSavedException', () async {
    when(() => repository.load()).thenAnswer((_) async => stored);
    when(
      () => repository.save(updated),
    ).thenThrow(const StatsStorageException());
    await expectLater(
      sut.record(result),
      throwsA(const GameResultNotSavedException()),
    );
  });

  test('unexpected error -> not translated', () async {
    when(() => repository.load()).thenThrow(StateError('bug'));
    await expectLater(sut.record(result), throwsStateError);
  });
}
