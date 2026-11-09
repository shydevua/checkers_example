import 'package:checkers_app/features/game/domain/game_domain.dart';
import 'package:flutter_test/flutter_test.dart';

Position p(int row, int col) => Position(row, col);

void main() {
  const evaluator = BoardEvaluator();

  group('constants', () {
    test('weights', () {
      expect(BoardEvaluator.manValue, 100);
      expect(BoardEvaluator.kingValue, 300);
      expect(BoardEvaluator.advanceBonus, 4);
      expect(BoardEvaluator.centerBonus, 6);
      expect(BoardEvaluator.backRankBonus, 8);
    });
  });

  group('pieceValue of a man', () {
    test('white man on its back rank -> man + guard', () {
      expect(evaluator.pieceValue(Piece.whiteMan, p(7, 2)), 108);
    });

    test('black man on its back rank -> man + guard', () {
      expect(evaluator.pieceValue(Piece.blackMan, p(0, 1)), 108);
    });

    test('white man one row up, off-center -> man + 1 advance', () {
      expect(evaluator.pieceValue(Piece.whiteMan, p(6, 1)), 104);
    });

    test(
      'white man in the center three rows up -> man + 3 advance + center',
      () {
        expect(evaluator.pieceValue(Piece.whiteMan, p(4, 3)), 118);
      },
    );

    test(
      'black man in the center two rows down -> man + 2 advance + center',
      () {
        expect(evaluator.pieceValue(Piece.blackMan, p(2, 3)), 114);
      },
    );

    test('black man six rows down at the edge -> man + 6 advance', () {
      expect(evaluator.pieceValue(Piece.blackMan, p(6, 7)), 124);
    });
  });

  group('pieceValue of a king (center boundaries)', () {
    test('row 1 -> not central', () {
      expect(evaluator.pieceValue(Piece.whiteKing, p(1, 4)), 300);
    });
    test('row 2 -> central', () {
      expect(evaluator.pieceValue(Piece.whiteKing, p(2, 3)), 306);
    });
    test('row 5 -> central', () {
      expect(evaluator.pieceValue(Piece.whiteKing, p(5, 2)), 306);
    });
    test('row 6 -> not central', () {
      expect(evaluator.pieceValue(Piece.whiteKing, p(6, 3)), 300);
    });
    test('col 1 -> not central', () {
      expect(evaluator.pieceValue(Piece.blackKing, p(4, 1)), 300);
    });
    test('col 2 -> central', () {
      expect(evaluator.pieceValue(Piece.blackKing, p(3, 2)), 306);
    });
    test('col 5 -> central', () {
      expect(evaluator.pieceValue(Piece.blackKing, p(2, 5)), 306);
    });
    test('col 6 -> not central', () {
      expect(evaluator.pieceValue(Piece.blackKing, p(3, 6)), 300);
    });
    test('king on its own back rank -> no guard bonus', () {
      expect(evaluator.pieceValue(Piece.whiteKing, p(7, 2)), 300);
    });
  });

  group('evaluate', () {
    final board = Board.fromPieces({
      p(4, 3): Piece.whiteKing,
      p(0, 1): Piece.blackMan,
    });

    test('own pieces add, opponent pieces subtract (white view)', () {
      expect(evaluator.evaluate(board, PieceColor.white), 306 - 108);
    });

    test('same board from black view -> negated', () {
      expect(evaluator.evaluate(board, PieceColor.black), 108 - 306);
    });

    test('empty board -> 0', () {
      expect(evaluator.evaluate(Board.empty(), PieceColor.white), 0);
    });

    test('initial position -> balanced', () {
      expect(evaluator.evaluate(Board.initial(), PieceColor.white), 0);
    });
  });
}
