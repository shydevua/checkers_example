import 'package:checkers_app/features/game/domain/game_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Position', () {
    test('corners 0,0 and 7,7 -> valid', () {
      expect(Position(0, 0).row, 0);
      expect(Position(0, 0).col, 0);
      expect(Position(7, 7).row, 7);
      expect(Position(7, 7).col, 7);
    });

    test('row -1 -> InvalidPositionException', () {
      expect(
        () => Position(-1, 0),
        throwsA(const InvalidPositionException(-1, 0)),
      );
    });

    test('row 8 -> InvalidPositionException', () {
      expect(
        () => Position(8, 0),
        throwsA(const InvalidPositionException(8, 0)),
      );
    });

    test('col -1 -> InvalidPositionException', () {
      expect(
        () => Position(0, -1),
        throwsA(const InvalidPositionException(0, -1)),
      );
    });

    test('col 8 -> InvalidPositionException', () {
      expect(
        () => Position(0, 8),
        throwsA(const InvalidPositionException(0, 8)),
      );
    });

    test('same coordinates -> same canonical instance and equal', () {
      expect(identical(Position(3, 4), Position(3, 4)), isTrue);
      expect(Position(3, 4), Position(3, 4));
      expect(Position(3, 4), isNot(Position(4, 3)));
    });

    test('index is row-major', () {
      expect(Position(0, 0).index, 0);
      expect(Position(2, 5).index, 21);
      expect(Position(7, 7).index, 63);
    });

    test('all has 64 squares in index order', () {
      expect(Position.all, hasLength(64));
      expect(Position.all[21], Position(2, 5));
    });

    test('notation: a1 bottom-left, h8 top-right', () {
      expect(Position(7, 0).notation, 'a1');
      expect(Position(0, 7).notation, 'h8');
      expect(Position(5, 2).notation, 'c3');
      expect(Position(4, 3).notation, 'd4');
    });

    test('isDark -> true when row + col is odd', () {
      expect(Position(0, 1).isDark, isTrue);
      expect(Position(0, 0).isDark, isFalse);
      expect(Position(7, 0).isDark, isTrue);
    });

    test('offset inside the board -> shifted square', () {
      expect(Position(3, 3).offset(-1, 1), Position(2, 4));
      expect(Position(3, 3).offset(1, -1), Position(4, 2));
    });

    test('offset to the last row/col -> still on board', () {
      expect(Position(6, 6).offset(1, 1), Position(7, 7));
      expect(Position(1, 1).offset(-1, -1), Position(0, 0));
    });

    test('offset past any edge -> null', () {
      expect(Position(0, 3).offset(-1, 0), isNull);
      expect(Position(7, 3).offset(1, 0), isNull);
      expect(Position(3, 0).offset(0, -1), isNull);
      expect(Position(3, 7).offset(0, 1), isNull);
    });
  });
}
