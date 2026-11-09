import 'package:checkers_app/features/game/domain/game_domain.dart';
import 'package:flutter_test/flutter_test.dart';

Position p(int row, int col) => Position(row, col);

void main() {
  const sut = SelectSquare();
  final a = p(5, 2);
  final b = p(3, 4);
  final c = p(1, 6);
  final d = p(3, 0);
  final e = p(5, 6);
  final f = p(4, 7);
  final single = Move([a, d], captured: [p(4, 1)]);
  final double = Move([a, b, c], captured: [p(4, 3), p(2, 5)]);
  final quiet = Move([e, f]);
  final moves = [single, double, quiet];

  Future<MoveSelection> tap(MoveSelection selection, Position position) =>
      sut(SelectSquareParams(selection: selection, position: position));

  test('nothing selected, tap a movable piece -> piece selected', () async {
    expect(await tap(MoveSelection(moves), a), MoveSelection(moves, path: [a]));
  });

  test('nothing selected, tap an empty square -> nothing selected', () async {
    expect(await tap(MoveSelection(moves), b), MoveSelection(moves));
  });

  test('piece selected, tap a target -> path extended', () async {
    expect(
      await tap(MoveSelection(moves, path: [a]), b),
      MoveSelection(moves, path: [a, b]),
    );
  });

  test('path extended to the end -> completed move', () async {
    final selection = await tap(MoveSelection(moves, path: [a, b]), c);
    expect(selection.completedMove, double);
  });

  test('piece selected, tap it again -> deselected', () async {
    expect(await tap(MoveSelection(moves, path: [a]), a), MoveSelection(moves));
  });

  test('piece selected, tap another movable piece -> switches', () async {
    expect(
      await tap(MoveSelection(moves, path: [a]), e),
      MoveSelection(moves, path: [e]),
    );
  });

  test(
    'capture in progress, tap the start piece -> restarts from it',
    () async {
      expect(
        await tap(MoveSelection(moves, path: [a, b]), a),
        MoveSelection(moves, path: [a]),
      );
    },
  );

  test('piece selected, tap a square that is no target -> cleared', () async {
    expect(await tap(MoveSelection(moves, path: [a]), f), MoveSelection(moves));
  });

  test('params equality', () {
    expect(
      SelectSquareParams(selection: MoveSelection(moves), position: a),
      SelectSquareParams(selection: MoveSelection(moves), position: a),
    );
    expect(
      SelectSquareParams(selection: MoveSelection(moves), position: a),
      isNot(SelectSquareParams(selection: MoveSelection(moves), position: b)),
    );
  });
}
