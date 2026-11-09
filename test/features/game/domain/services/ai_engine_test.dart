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

  setUp(() => random = _MockRandom());

  // White man on (5,2); stepping to (4,3) is captured by the black man on
  // (3,4), stepping to (4,1) is safe.
  final trap = rules.gameFrom(
    Board.fromPieces({p(5, 2): Piece.whiteMan, p(3, 4): Piece.blackMan}),
    turn: PieceColor.white,
  );
  final safe = Move([p(5, 2), p(4, 1)]);
  final blunder = Move([p(5, 2), p(4, 3)]);

  // Both moves of the white man are equally good.
  final symmetric = rules.gameFrom(
    Board.fromPieces({p(5, 4): Piece.whiteMan, p(0, 1): Piece.blackMan}),
    turn: PieceColor.white,
  );

  group('bestMove', () {
    test('finished game -> GameAlreadyOverException, random unused', () {
      final over = rules.gameFrom(
        Board.initial(),
        turn: PieceColor.white,
        quietKingMoves: 30,
      );
      expect(
        () => engine.bestMove(over, Difficulty.hard, random),
        throwsA(const GameAlreadyOverException()),
      );
      verifyZeroInteractions(random);
    });

    test('single legal move -> played without search or randomness', () {
      final game = rules.gameFrom(
        Board.fromPieces({p(5, 0): Piece.whiteMan, p(0, 1): Piece.blackMan}),
        turn: PieceColor.white,
      );
      expect(
        engine.bestMove(game, Difficulty.easy, random),
        Move([p(5, 0), p(4, 1)]),
      );
      verifyZeroInteractions(random);
    });

    test('roll below randomMoveChance -> random legal move', () {
      when(() => random.nextDouble()).thenReturn(0.49);
      when(() => random.nextInt(2)).thenReturn(1);
      expect(engine.bestMove(trap, Difficulty.easy, random), blunder);
      verify(() => random.nextInt(2)).called(1);
    });

    test('roll equal to randomMoveChance -> searched move', () {
      when(() => random.nextDouble()).thenReturn(0.5);
      when(() => random.nextInt(1)).thenReturn(0);
      expect(engine.bestMove(trap, Difficulty.easy, random), safe);
      verify(() => random.nextInt(1)).called(1);
    });

    test('medium searches when the roll is 0.1', () {
      when(() => random.nextDouble()).thenReturn(0.1);
      when(() => random.nextInt(1)).thenReturn(0);
      expect(engine.bestMove(trap, Difficulty.medium, random), safe);
    });

    test('hard never plays randomly, even on a roll of 0', () {
      when(() => random.nextDouble()).thenReturn(0);
      when(() => random.nextInt(1)).thenReturn(0);
      expect(engine.bestMove(trap, Difficulty.hard, random), safe);
    });

    test('tied best moves -> random picks among them', () {
      when(() => random.nextDouble()).thenReturn(0.99);
      when(() => random.nextInt(2)).thenReturn(1);
      expect(
        engine.bestMoveWith(
          symmetric,
          const SearchSettings(maxDepth: 1, randomMoveChance: 0.1),
          random,
        ),
        Move([p(5, 4), p(4, 5)]),
      );
      verify(() => random.nextInt(2)).called(1);
    });

    test('time limit -> answers within the budget with a legal move', () {
      final game = rules.newGame();
      final clock = Stopwatch()..start();
      final move = engine.bestMoveWith(
        game,
        const SearchSettings(
          maxDepth: 30,
          randomMoveChance: 0,
          timeLimit: Duration(milliseconds: 100),
        ),
        Random(1),
      );
      expect(clock.elapsed, lessThan(const Duration(seconds: 1)));
      expect(game.legalMoves, contains(move));
    });

    test('no time left even for depth 1 -> still a legal move', () {
      final game = rules.newGame();
      final move = engine.bestMoveWith(
        game,
        const SearchSettings(
          maxDepth: 5,
          randomMoveChance: 0,
          timeLimit: Duration.zero,
        ),
        Random(1),
      );
      expect(game.legalMoves, contains(move));
    });

    test('hard from the initial position -> a legal move', () {
      final game = rules.newGame();
      final move = engine.bestMove(game, Difficulty.hard, Random(1));
      expect(game.legalMoves, contains(move));
    });
  });

  group('bestMoves', () {
    test('depth 1 still sees the forced recapture -> only the safe move', () {
      expect(
        engine.bestMoves(trap.board, PieceColor.white, trap.legalMoves, 1),
        [safe],
      );
    });

    test('equal moves -> all of them in original order', () {
      expect(
        engine.bestMoves(
          symmetric.board,
          PieceColor.white,
          symmetric.legalMoves,
          1,
        ),
        [
          Move([p(5, 4), p(4, 3)]),
          Move([p(5, 4), p(4, 5)]),
        ],
      );
    });

    test('prefers winning material over a quiet move', () {
      // White king can take the black man on (4,3) or step aside.
      final game = rules.gameFrom(
        Board.fromPieces({
          p(7, 0): Piece.whiteKing,
          p(4, 3): Piece.blackMan,
          p(0, 1): Piece.blackMan,
          p(0, 3): Piece.blackMan,
        }),
        turn: PieceColor.white,
      );
      final best = engine.bestMoves(
        game.board,
        PieceColor.white,
        game.legalMoves,
        3,
      );
      expect(best.every((m) => m.isCapture), isTrue);
    });

    test('a quicker win scores higher than a slower one', () {
      // Capturing the last black piece wins at once.
      final game = rules.gameFrom(
        Board.fromPieces({
          p(5, 2): Piece.whiteMan,
          p(4, 3): Piece.blackMan,
        }),
        turn: PieceColor.white,
      );
      expect(
        engine.bestMoves(game.board, PieceColor.white, game.legalMoves, 4),
        [
          Move([p(5, 2), p(3, 4)], captured: [p(4, 3)]),
        ],
      );
    });
  });

  group('score', () {
    test('side to move without moves -> -winScore at ply 0', () {
      final board = Board.fromPieces({p(5, 2): Piece.whiteMan});
      expect(engine.score(board, PieceColor.black, 3), -AiEngine.winScore);
    });

    test('quiet position at depth 0 -> static evaluation', () {
      final board = Board.fromPieces({
        p(4, 3): Piece.whiteKing,
        p(0, 1): Piece.blackMan,
      });
      expect(
        engine.score(board, PieceColor.white, 0),
        const BoardEvaluator().evaluate(board, PieceColor.white),
      );
    });

    test('pending capture at depth 0 -> searched to the end', () {
      final board = Board.fromPieces({
        p(5, 2): Piece.whiteMan,
        p(4, 3): Piece.blackMan,
      });
      expect(engine.score(board, PieceColor.white, 0), AiEngine.winScore - 1);
    });

    test('win found at depth 2 -> winScore minus plies', () {
      final board = Board.fromPieces({
        p(5, 2): Piece.whiteMan,
        p(4, 3): Piece.blackMan,
      });
      expect(engine.score(board, PieceColor.white, 2), AiEngine.winScore - 1);
    });

    test('winScore', () {
      expect(AiEngine.winScore, 1000000);
    });

    // White man 5,6 (108) against black man 1,2 (104). White can go to 4,5
    // (118) or 4,7 (112); black then to 2,1 (108) or 2,3 (114).
    final quiet = Board.fromPieces({
      p(5, 6): Piece.whiteMan,
      p(1, 2): Piece.blackMan,
    });

    test('depth 1 -> best white move evaluated: 118 - 104', () {
      expect(engine.score(quiet, PieceColor.white, 1), 14);
    });

    test('depth 2 -> black answers with its best reply: 118 - 114', () {
      expect(engine.score(quiet, PieceColor.white, 2), 4);
    });

    test('depth 2 from black -> 114 - 118 after the best replies', () {
      expect(engine.score(quiet, PieceColor.black, 2), -4);
    });

    test('moveScore 5,6-4,5 at depth 2 -> after the best reply: 4', () {
      expect(
        engine.moveScore(quiet, PieceColor.white, Move([p(5, 6), p(4, 5)]), 2),
        4,
      );
    });

    test('moveScore 5,6-4,7 at depth 1 -> 112 - 104', () {
      expect(
        engine.moveScore(quiet, PieceColor.white, Move([p(5, 6), p(4, 7)]), 1),
        8,
      );
    });

    test('moveScore of the winning capture -> winScore - 1 (one ply)', () {
      final board = Board.fromPieces({
        p(5, 2): Piece.whiteMan,
        p(4, 3): Piece.blackMan,
      });
      final capture = Move([p(5, 2), p(3, 4)], captured: [p(4, 3)]);
      expect(
        engine.moveScore(board, PieceColor.white, capture, 3),
        AiEngine.winScore - 1,
      );
    });

    test('bestMoves at depth 2 -> the central move', () {
      expect(
        engine.bestMoves(
          quiet,
          PieceColor.white,
          const CheckersRules().legalMoves(quiet, PieceColor.white),
          2,
        ),
        [
          Move([p(5, 6), p(4, 5)]),
        ],
      );
    });
  });
}
