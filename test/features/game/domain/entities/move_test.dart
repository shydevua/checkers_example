import 'package:checkers_app/features/game/domain/game_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Move', () {
    test('quiet move -> from, to, not a capture', () {
      final move = Move([Position(5, 2), Position(4, 3)]);
      expect(move.from, Position(5, 2));
      expect(move.to, Position(4, 3));
      expect(move.captured, isEmpty);
      expect(move.isCapture, isFalse);
    });

    test('capture -> isCapture and captured squares', () {
      final move = Move(
        [Position(5, 2), Position(3, 4), Position(1, 2)],
        captured: [Position(4, 3), Position(2, 3)],
      );
      expect(move.isCapture, isTrue);
      expect(move.to, Position(1, 2));
      expect(move.captured, [Position(4, 3), Position(2, 3)]);
    });

    test('quiet move notation uses a dash', () {
      expect(Move([Position(5, 2), Position(4, 3)]).notation, 'c3-d4');
    });

    test('capture notation lists every landing square with colons', () {
      final move = Move(
        [Position(5, 2), Position(3, 4), Position(1, 6)],
        captured: [Position(4, 3), Position(2, 5)],
      );
      expect(move.notation, 'c3:e5:g7');
    });

    test('path of one square -> ArgumentError', () {
      expect(
        () => Move([Position(5, 2)]),
        throwsA(
          isA<ArgumentError>()
              .having((e) => e.name, 'name', 'path')
              .having(
                (e) => e.message,
                'message',
                'needs at least two squares',
              ),
        ),
      );
    });

    test('path of two squares -> valid', () {
      expect(Move([Position(5, 2), Position(4, 1)]).path, hasLength(2));
    });

    test('path and captured are unmodifiable copies', () {
      final path = [Position(5, 2), Position(4, 1)];
      final move = Move(path);
      path.add(Position(3, 0));
      expect(move.path, hasLength(2));
      expect(() => move.path.add(Position(3, 0)), throwsUnsupportedError);
      expect(() => move.captured.add(Position(3, 0)), throwsUnsupportedError);
    });

    test('equality uses path and captured', () {
      final path = [Position(5, 2), Position(3, 4)];
      expect(Move(path), Move(path));
      expect(Move(path), isNot(Move(path, captured: [Position(4, 3)])));
    });
  });
}
