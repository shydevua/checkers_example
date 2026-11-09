import 'package:checkers_app/features/game/domain/game_domain.dart';
import 'package:checkers_app/features/shared/game_results/difficulty.dart';
import 'package:checkers_app/features/shared/game_results/game_outcome.dart';
import 'package:checkers_app/features/shared/game_results/game_result.dart';
import 'package:checkers_app/features/shared/game_results/game_result_exception.dart';
import 'package:checkers_app/features/shared/game_results/game_result_recorder.dart';
import 'package:checkers_app/features/shared/game_results/level_stats.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRecorder extends Mock implements GameResultRecorder {}

void main() {
  late _MockRecorder recorder;
  late SaveGameResult sut;
  const result = GameResult(
    difficulty: Difficulty.easy,
    outcome: GameOutcome.loss,
  );

  setUp(() {
    recorder = _MockRecorder();
    sut = SaveGameResult(recorder);
  });

  test('hands the result to the recorder and returns its totals', () async {
    when(() => recorder.record(result)).thenAnswer(
      (_) async => LevelStats(losses: 3),
    );
    expect(await sut(result), LevelStats(losses: 3));
    verify(() => recorder.record(result)).called(1);
    verifyNoMoreInteractions(recorder);
  });

  test('GameResultNotSavedException -> propagates', () async {
    when(
      () => recorder.record(result),
    ).thenThrow(const GameResultNotSavedException());
    await expectLater(
      sut(result),
      throwsA(const GameResultNotSavedException()),
    );
  });
}
