import 'dart:math';

import 'package:checkers_app/features/game/domain/game_domain.dart';
import 'package:checkers_app/features/shared/game_results/difficulty.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRandom extends Mock implements Random {}

Position p(int row, int col) => Position(row, col);

void main() {
  const rules = CheckersRules();
  const engine = AiEngine();
  late _MockRandom random;
  late ComputeAiMove sut;

  setUp(() {
    random = _MockRandom();
    sut = ComputeAiMove(engine, random);
  });

  test('finished game -> GameAlreadyOverException, no seed drawn', () async {
    final over = rules.gameFrom(
      Board.fromPieces({p(5, 2): Piece.whiteMan}),
      turn: PieceColor.black,
    );
    await expectLater(
      sut(ComputeAiMoveParams(game: over, difficulty: Difficulty.easy)),
      throwsA(const GameAlreadyOverException()),
    );
    verifyZeroInteractions(random);
  });

  test('single legal move -> that move', () async {
    when(() => random.nextInt(ComputeAiMove.maxSeed)).thenReturn(3);
    final game = rules.gameFrom(
      Board.fromPieces({p(2, 7): Piece.blackMan, p(7, 0): Piece.whiteMan}),
      turn: PieceColor.black,
    );
    expect(
      await sut(ComputeAiMoveParams(game: game, difficulty: Difficulty.hard)),
      Move([p(2, 7), p(3, 6)]),
    );
  });

  test('move equals the engine result for the drawn seed', () async {
    when(() => random.nextInt(ComputeAiMove.maxSeed)).thenReturn(7);
    final game = rules.play(rules.newGame(), Move([p(5, 2), p(4, 3)]));
    final move = await sut(
      ComputeAiMoveParams(game: game, difficulty: Difficulty.easy),
    );
    expect(move, engine.bestMove(game, Difficulty.easy, Random(7)));
    verify(() => random.nextInt(1 << 32)).called(1);
  });

  test('maxSeed is 2^32', () {
    expect(ComputeAiMove.maxSeed, 4294967296);
  });

  test('params equality', () {
    final game = rules.newGame();
    expect(
      ComputeAiMoveParams(game: game, difficulty: Difficulty.easy),
      ComputeAiMoveParams(game: game, difficulty: Difficulty.easy),
    );
    expect(
      ComputeAiMoveParams(game: game, difficulty: Difficulty.easy),
      isNot(ComputeAiMoveParams(game: game, difficulty: Difficulty.hard)),
    );
  });
}
