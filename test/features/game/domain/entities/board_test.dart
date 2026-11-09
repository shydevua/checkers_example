import 'package:checkers_app/features/game/domain/game_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Board', () {
    test('empty -> no pieces', () {
      final board = Board.empty();
      expect(board.countOf(PieceColor.white), 0);
      expect(board.countOf(PieceColor.black), 0);
      expect(board.isEmptyAt(Position(0, 1)), isTrue);
    });

    test('initial -> 12 men per side on dark squares of rows 0-2 and 5-7', () {
      final board = Board.initial();
      expect(board.countOf(PieceColor.black), 12);
      expect(board.countOf(PieceColor.white), 12);
      expect(board.pieceAt(Position(0, 1)), Piece.blackMan);
      expect(board.pieceAt(Position(2, 7)), Piece.blackMan);
      expect(board.pieceAt(Position(5, 0)), Piece.whiteMan);
      expect(board.pieceAt(Position(7, 6)), Piece.whiteMan);
    });

    test('initial -> rows 3 and 4 and light squares are empty', () {
      final board = Board.initial();
      expect(board.pieceAt(Position(3, 0)), isNull);
      expect(board.pieceAt(Position(4, 1)), isNull);
      expect(board.pieceAt(Position(0, 0)), isNull);
      expect(board.pieceAt(Position(7, 7)), isNull);
    });

    test('positionsOf -> squares of that color in index order', () {
      final board = Board.fromPieces({
        Position(5, 2): Piece.whiteMan,
        Position(0, 1): Piece.blackMan,
        Position(1, 0): Piece.whiteKing,
      });
      expect(board.positionsOf(PieceColor.white), [
        Position(1, 0),
        Position(5, 2),
      ]);
      expect(board.positionsOf(PieceColor.black), [Position(0, 1)]);
    });

    test('fromPieces on a light square -> ArgumentError', () {
      expect(
        () => Board.fromPieces({Position(0, 0): Piece.whiteMan}),
        throwsA(
          isA<ArgumentError>()
              .having((e) => e.name, 'name', 'position')
              .having((e) => e.message, 'message', 'is a light square'),
        ),
      );
    });

    test('updated -> new board, original untouched', () {
      final original = Board.fromPieces({Position(5, 2): Piece.whiteMan});
      final updated = original.updated({
        Position(5, 2): null,
        Position(4, 3): Piece.whiteKing,
      });
      expect(original.pieceAt(Position(5, 2)), Piece.whiteMan);
      expect(updated.pieceAt(Position(5, 2)), isNull);
      expect(updated.pieceAt(Position(4, 3)), Piece.whiteKing);
    });

    test('updated with null on a light square -> allowed', () {
      expect(Board.empty().updated({Position(0, 0): null}), Board.empty());
    });

    test('equality compares every square', () {
      expect(Board.initial(), Board.initial());
      expect(
        Board.initial(),
        isNot(Board.initial().updated({Position(5, 0): null})),
      );
    });
  });
}
