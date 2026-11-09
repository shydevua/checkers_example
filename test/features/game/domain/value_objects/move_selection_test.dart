import 'package:checkers_app/features/game/domain/game_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final a = Position(5, 2);
  final b = Position(3, 4);
  final c = Position(1, 6);
  final d = Position(3, 0);
  final e = Position(5, 6);
  final f = Position(4, 7);
  // Two captures from a (one of them double) and a quiet move from e.
  final single = Move([a, d], captured: [Position(4, 1)]);
  final double = Move([a, b, c], captured: [Position(4, 3), Position(2, 5)]);
  final quiet = Move([e, f]);
  final moves = [single, double, quiet];

  final notAPrefix = isA<ArgumentError>()
      .having((e) => e.name, 'name', 'path')
      .having((e) => e.message, 'message', 'is not a prefix of a legal move');

  group('MoveSelection', () {
    test('empty path -> every origin movable, no targets, not completed', () {
      final selection = MoveSelection(moves);
      expect(selection.legalMoves, moves);
      expect(selection.path, isEmpty);
      expect(selection.movable, {a, e});
      expect(selection.targets, isEmpty);
      expect(selection.completedMove, isNull);
      expect(selection.current, isNull);
    });

    test('origin selected -> next squares of its moves are targets', () {
      final selection = MoveSelection(moves, path: [a]);
      expect(selection.targets, {d, b});
      expect(selection.completedMove, isNull);
      expect(selection.current, a);
      expect(selection.movable, {a, e});
    });

    test('partial capture path -> only the continuation is a target', () {
      final selection = MoveSelection(moves, path: [a, b]);
      expect(selection.targets, {c});
      expect(selection.completedMove, isNull);
      expect(selection.current, b);
    });

    test('full path -> completedMove is that move and no targets', () {
      final selection = MoveSelection(moves, path: [a, b, c]);
      expect(selection.completedMove, double);
      expect(selection.targets, isEmpty);
    });

    test('two-square path -> completes a simple move', () {
      expect(MoveSelection(moves, path: [e, f]).completedMove, quiet);
      expect(MoveSelection(moves, path: [a, d]).completedMove, single);
    });

    test('path that is no legal prefix -> ArgumentError', () {
      expect(() => MoveSelection(moves, path: [b]), throwsA(notAPrefix));
      expect(() => MoveSelection(moves, path: [a, c]), throwsA(notAPrefix));
    });

    test('path longer than every move -> ArgumentError', () {
      expect(
        () => MoveSelection(moves, path: [e, f, Position(3, 6)]),
        throwsA(notAPrefix),
      );
    });

    test('equality depends on legal moves and path', () {
      expect(MoveSelection(moves, path: [a]), MoveSelection(moves, path: [a]));
      expect(MoveSelection(moves, path: [a]), isNot(MoveSelection(moves)));
      expect(MoveSelection(moves), isNot(MoveSelection([quiet])));
    });

    test('none -> nothing selected and nothing selectable', () {
      expect(MoveSelection.none, MoveSelection(const []));
      expect(MoveSelection.none.movable, isEmpty);
      expect(MoveSelection.none.targets, isEmpty);
      expect(MoveSelection.none.completedMove, isNull);
    });
  });
}
