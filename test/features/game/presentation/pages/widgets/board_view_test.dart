import 'package:checkers_app/core/l10n/l10n.dart';
import 'package:checkers_app/features/game/domain/game_domain.dart';
import 'package:checkers_app/features/game/presentation/pages/widgets/board_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Position p(int row, int col) => Position(row, col);

void main() {
  const rules = CheckersRules();
  final tapped = <Position>[];
  final legal = rules.newGame().legalMoves;
  final move = Move([p(5, 2), p(4, 3)]);
  final after = rules.apply(Board.initial(), move);

  Widget app(Widget child, {bool disableAnimations = false}) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: MediaQuery(
      data: MediaQueryData(
        size: const Size(416, 416),
        disableAnimations: disableAnimations,
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox.square(dimension: 416, child: child),
      ),
    ),
  );

  BoardView view({
    Board? board,
    MoveSelection? selection,
    Move? lastMove,
    bool flipped = false,
  }) => BoardView(
    board: board ?? Board.initial(),
    selection: selection ?? MoveSelection(legal),
    lastMove: lastMove,
    flipped: flipped,
    onSquareTap: tapped.add,
  );

  setUp(tapped.clear);

  testWidgets('tap -> reports the square under the finger', (tester) async {
    await tester.pumpWidget(app(view()));
    // 416 px board, 8 px frame -> 50 px squares starting at 8,8.
    await tester.tapAt(const Offset(8 + 2.5 * 50, 8 + 5.5 * 50));
    await tester.tapAt(const Offset(8 + 7.5 * 50, 8 + 0.5 * 50));
    expect(tapped, [p(5, 2), p(0, 7)]);
  });

  testWidgets('flipped board -> taps are mirrored', (tester) async {
    await tester.pumpWidget(app(view(flipped: true)));
    await tester.tapAt(const Offset(8 + 2.5 * 50, 8 + 5.5 * 50));
    expect(tapped, [p(2, 5)]);
  });

  testWidgets('board is isolated in its own repaint boundary', (tester) async {
    await tester.pumpWidget(app(view()));
    expect(
      find.descendant(
        of: find.byType(BoardView),
        matching: find.byType(RepaintBoundary),
      ),
      findsOneWidget,
    );
  });

  testWidgets('screen reader: board label, squares and tap action', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(app(view()));
    expect(find.bySemanticsLabel('Board, you play white'), findsOneWidget);
    final c3 = find.semantics.byLabel('c3, white man, can move');
    expect(c3, findsOne);
    tester.semantics.tap(c3);
    expect(tapped, [p(5, 2)]);
    semantics.dispose();
  });

  testWidgets('screen reader: black side is announced', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(app(view(flipped: true)));
    expect(find.bySemanticsLabel('Board, you play black'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('new move -> animated, one step per square', (tester) async {
    await tester.pumpWidget(app(view()));
    await tester.pumpWidget(
      app(view(board: after, selection: MoveSelection.none, lastMove: move)),
    );
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pump(BoardView.stepDuration * 1.5);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('capture path -> the animation lasts one step per segment', (
    tester,
  ) async {
    final board = Board.fromPieces({
      p(5, 0): Piece.whiteMan,
      p(4, 1): Piece.blackMan,
      p(2, 3): Piece.blackKing,
    });
    final capture = rules.legalMoves(board, PieceColor.white).single;
    await tester.pumpWidget(app(view(board: board)));
    await tester.pumpWidget(
      app(
        view(
          board: rules.apply(board, capture),
          selection: MoveSelection.none,
          lastMove: capture,
        ),
      ),
    );
    await tester.pump(BoardView.stepDuration * 1.5);
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pump(BoardView.stepDuration);
    expect(tester.hasRunningAnimations, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('animations disabled in the system -> no animation', (
    tester,
  ) async {
    await tester.pumpWidget(app(view(), disableAnimations: true));
    await tester.pumpWidget(
      app(
        view(board: after, selection: MoveSelection.none, lastMove: move),
        disableAnimations: true,
      ),
    );
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('same move again -> no new animation', (tester) async {
    await tester.pumpWidget(
      app(view(board: after, selection: MoveSelection.none, lastMove: move)),
    );
    await tester.pumpWidget(app(view(board: after, lastMove: move)));
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('kings and a partial capture paint', (tester) async {
    final board = Board.fromPieces({
      p(2, 1): Piece.whiteMan,
      p(1, 2): Piece.blackMan,
      p(2, 5): Piece.blackMan,
      p(6, 1): Piece.blackKing,
    });
    final moves = rules.legalMoves(board, PieceColor.white);
    await tester.pumpWidget(
      app(
        view(
          board: board,
          selection: MoveSelection(moves, path: [p(2, 1), p(0, 3)]),
          lastMove: Move([p(7, 0), p(6, 1)]),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
