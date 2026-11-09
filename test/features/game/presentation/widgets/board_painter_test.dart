import 'package:checkers_app/core/l10n/l10n.dart';
import 'package:checkers_app/features/game/domain/game_domain.dart';
import 'package:checkers_app/features/game/presentation/widgets/board_painter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Position p(int row, int col) => Position(row, col);

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));
  final board = Board.initial();
  final legal = const CheckersRules().newGame().legalMoves;
  final selection = MoveSelection(legal);
  final move = Move([p(5, 2), p(4, 3)]);
  final tapped = <Position>[];

  BoardPainter painter({
    Board? b,
    MoveSelection? s,
    Move? m,
    bool flipped = false,
  }) => BoardPainter(
    board: b ?? board,
    selection: s ?? selection,
    lastMove: m,
    flipped: flipped,
    l10n: l10n,
    textDirection: TextDirection.ltr,
    onSquareTap: tapped.add,
  );

  setUp(tapped.clear);

  group('shouldRepaint', () {
    test('same inputs -> false', () {
      expect(painter().shouldRepaint(painter()), isFalse);
    });

    test('other board, selection, last move or side -> true', () {
      expect(painter(b: Board.empty()).shouldRepaint(painter()), isTrue);
      expect(painter(s: MoveSelection.none).shouldRepaint(painter()), isTrue);
      expect(painter(m: move).shouldRepaint(painter()), isTrue);
      expect(painter(flipped: true).shouldRepaint(painter()), isTrue);
    });

    test('semantics rebuild only when what they describe changes', () {
      expect(painter().shouldRebuildSemantics(painter()), isFalse);
      expect(painter(m: move).shouldRebuildSemantics(painter()), isTrue);
    });
  });

  group('semantics', () {
    List<CustomPainterSemantics> nodes(BoardPainter p) =>
        p.semanticsBuilder(const Size(400, 400));

    CustomPainterSemantics node(BoardPainter p, String square) =>
        nodes(p).firstWhere((n) => n.key == ValueKey(square));

    test('one node per dark square', () {
      expect(nodes(painter()), hasLength(32));
    });

    test('movable piece -> label, select hint, button with tap', () {
      final c3 = node(painter(), 'c3');
      expect(c3.properties.label, 'c3, white man, can move');
      expect(c3.properties.hint, 'select the piece');
      expect(c3.properties.button, isTrue);
      expect(c3.properties.textDirection, TextDirection.ltr);
      c3.properties.onTap!();
      expect(tapped, [p(5, 2)]);
    });

    test('piece that cannot move -> no action', () {
      final a1 = node(painter(), 'a1');
      expect(a1.properties.label, 'a1, white man');
      expect(a1.properties.onTap, isNull);
      expect(a1.properties.hint, isNull);
    });

    test('empty square -> empty', () {
      expect(node(painter(), 'd4').properties.label, 'd4, empty');
    });

    test('selected piece and its targets', () {
      final selected = MoveSelection(legal, path: [p(5, 2)]);
      final c3 = node(painter(s: selected), 'c3');
      expect(c3.properties.label, 'c3, white man, selected');
      expect(c3.properties.selected, isTrue);
      final d4 = node(painter(s: selected), 'd4');
      expect(d4.properties.label, 'd4, empty, you can move here');
      expect(d4.properties.hint, 'move here');
      d4.properties.onTap!();
      expect(tapped, [p(4, 3)]);
    });

    test('last move squares are marked', () {
      final after = const CheckersRules().apply(board, move);
      expect(
        node(
          painter(b: after, s: MoveSelection.none, m: move),
          'd4',
        ).properties.label,
        'd4, white man, last move',
      );
    });

    test('node rects follow the side at the bottom', () {
      expect(node(painter(), 'a1').rect, const Rect.fromLTWH(0, 350, 50, 50));
      expect(
        node(painter(flipped: true), 'a1').rect,
        const Rect.fromLTWH(350, 0, 50, 50),
      );
    });
  });

  test('pieceKind -> l10n select keys', () {
    expect(pieceKind(null), 'none');
    expect(pieceKind(Piece.whiteMan), 'whiteMan');
    expect(pieceKind(Piece.blackMan), 'blackMan');
    expect(pieceKind(Piece.whiteKing), 'whiteKing');
    expect(pieceKind(Piece.blackKing), 'blackKing');
  });

  group('positionAt', () {
    test('top-left corner -> 0,0', () {
      expect(positionAt(Offset.zero, 400), p(0, 0));
    });

    test('center of a square -> that square', () {
      expect(positionAt(const Offset(125, 275), 400), p(5, 2));
    });

    test('square boundary belongs to the next square', () {
      expect(positionAt(const Offset(50, 50), 400), p(1, 1));
      expect(positionAt(const Offset(49.9, 49.9), 400), p(0, 0));
    });

    test('edges and outside -> nearest square', () {
      expect(positionAt(const Offset(400, 400), 400), p(7, 7));
      expect(positionAt(const Offset(-5, 450), 400), p(7, 0));
    });

    test('flipped board -> mirrored square', () {
      expect(positionAt(Offset.zero, 400, flipped: true), p(7, 7));
      expect(positionAt(const Offset(125, 275), 400, flipped: true), p(2, 5));
    });
  });

  test('squareRect mirrors when flipped', () {
    expect(squareRect(p(0, 0), 50), const Rect.fromLTWH(0, 0, 50, 50));
    expect(
      squareRect(p(0, 0), 50, flipped: true),
      const Rect.fromLTWH(350, 350, 50, 50),
    );
  });
}
