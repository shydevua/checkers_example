// Behaviour of the levels, not their constants: deeper search plays
// better moves and wins games against shallower search.
import 'dart:math';

import 'package:checkers_app/features/game/domain/game_domain.dart';
import 'package:checkers_app/features/shared/game_results/difficulty.dart';
import 'package:checkers_app/features/shared/game_results/game_outcome.dart';
import 'package:flutter_test/flutter_test.dart';

Position p(int row, int col) => Position(row, col);

void main() {
  const rules = CheckersRules();
  const engine = AiEngine();

  // White can crown at once (a7-b8) or sacrifice with c5-b6: black must
  // capture and white wins more material afterwards.
  final shot = Board.fromPieces({
    p(4, 1): Piece.whiteMan,
    p(1, 0): Piece.whiteMan,
    p(3, 0): Piece.whiteMan,
    p(3, 2): Piece.whiteMan,
    p(0, 5): Piece.blackMan,
    p(5, 4): Piece.blackMan,
    p(0, 7): Piece.blackMan,
    p(5, 0): Piece.blackMan,
  });
  final moves = rules.legalMoves(shot, PieceColor.white);
  final sacrifice = moves.singleWhere((m) => m.notation == 'c5-b6');
  final crowning = moves.singleWhere((m) => m.notation == 'a7-b8');

  test('one half-move ahead -> takes the obvious crowning', () {
    expect(engine.bestMoves(shot, PieceColor.white, moves, 1), [crowning]);
  });

  test('five half-moves ahead -> finds the sacrifice combination', () {
    expect(engine.bestMoves(shot, PieceColor.white, moves, 5), [sacrifice]);
  });

  test('after the sacrifice black has only captures', () {
    final replies = rules.legalMoves(
      rules.apply(shot, sacrifice),
      PieceColor.black,
    );
    expect(replies, isNotEmpty);
    expect(replies.every((m) => m.isCapture), isTrue);
  });

  test('medium beats easy in most games', () {
    var mediumWins = 0;
    for (var seed = 0; seed < 4; seed++) {
      final random = Random(seed);
      var game = rules.newGame();
      for (var ply = 0; ply < 200 && !game.isOver; ply++) {
        final level = game.turn == PieceColor.white
            ? Difficulty.medium
            : Difficulty.easy;
        game = rules.play(game, engine.bestMove(game, level, random));
      }
      if (game.outcomeFor(PieceColor.white) == GameOutcome.win) mediumWins++;
    }
    expect(mediumWins, greaterThanOrEqualTo(3));
  });
}
