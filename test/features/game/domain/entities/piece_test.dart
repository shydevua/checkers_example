import 'package:checkers_app/features/game/domain/game_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PieceColor', () {
    test('opponent', () {
      expect(PieceColor.white.opponent, PieceColor.black);
      expect(PieceColor.black.opponent, PieceColor.white);
    });

    test('forward: white goes up, black goes down', () {
      expect(PieceColor.white.forward, -1);
      expect(PieceColor.black.forward, 1);
    });

    test('promotionRow: white on row 0, black on row 7', () {
      expect(PieceColor.white.promotionRow, 0);
      expect(PieceColor.black.promotionRow, 7);
    });
  });

  group('Piece', () {
    test('men are not kings by default', () {
      expect(Piece(PieceColor.values.last).isKing, isFalse);
    });

    test('constants have the expected color and kind', () {
      expect(Piece.whiteMan.color, PieceColor.white);
      expect(Piece.whiteMan.isKing, isFalse);
      expect(Piece.blackMan.color, PieceColor.black);
      expect(Piece.blackMan.isKing, isFalse);
      expect(Piece.whiteKing.color, PieceColor.white);
      expect(Piece.whiteKing.isKing, isTrue);
      expect(Piece.blackKing.color, PieceColor.black);
      expect(Piece.blackKing.isKing, isTrue);
    });

    test('crowned -> king of the same color', () {
      expect(Piece.whiteMan.crowned(), Piece.whiteKing);
      expect(Piece.blackMan.crowned(), Piece.blackKing);
      expect(Piece.blackKing.crowned(), Piece.blackKing);
    });

    test('equality uses color and kind', () {
      expect(Piece.whiteMan, isNot(Piece.blackMan));
      expect(Piece.whiteMan, isNot(Piece.whiteKing));
    });
  });
}
