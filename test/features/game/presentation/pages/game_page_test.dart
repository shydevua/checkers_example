import 'package:bloc_test/bloc_test.dart';
import 'package:checkers_app/features/game/domain/game_domain.dart';
import 'package:checkers_app/features/game/presentation/bloc/game/game_bloc.dart';
import 'package:checkers_app/features/game/presentation/bloc/game/game_event.dart';
import 'package:checkers_app/features/game/presentation/bloc/game/game_state.dart';
import 'package:checkers_app/features/game/presentation/pages/game_page.dart';
import 'package:checkers_app/features/game/presentation/pages/widgets/board_view.dart';
import 'package:checkers_app/features/shared/game_results/difficulty.dart';
import 'package:checkers_app/features/shared/game_results/game_outcome.dart';
import 'package:checkers_app/features/shared/game_results/game_result_exception.dart';
import 'package:checkers_app/features/shared/game_results/level_stats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/pump_app.dart';

class _MockGameBloc extends MockBloc<GameEvent, GameState>
    implements GameBloc {}

Position p(int row, int col) => Position(row, col);

void main() {
  late _MockGameBloc bloc;
  const rules = CheckersRules();
  const easy = Difficulty.easy;
  final newGame = rules.newGame();
  final capture = rules.gameFrom(
    Board.fromPieces({p(5, 2): Piece.whiteMan, p(4, 3): Piece.blackMan}),
    turn: PieceColor.white,
  );
  final won = rules.play(capture, capture.legalMoves.single);

  setUp(() => bloc = _MockGameBloc());

  Future<void> pump(WidgetTester tester, GameState state) async {
    when(() => bloc.state).thenReturn(state);
    await tester.pumpApp(
      BlocProvider<GameBloc>.value(
        value: bloc,
        child: const GamePage(difficulty: easy),
      ),
    );
  }

  GameInProgress playing(
    Game game, {
    bool aiThinking = false,
    List<Game> history = const [],
  }) => GameInProgress(
    difficulty: easy,
    game: game,
    selection: aiThinking ? MoveSelection.none : MoveSelection(game.legalMoves),
    aiThinking: aiThinking,
    history: history,
  );

  IconButton undo(WidgetTester tester) =>
      tester.widget<IconButton>(find.byKey(const ValueKey('game-undo')));

  testWidgets('title shows the level', (tester) async {
    await pump(tester, const GameInitial());
    expect(find.text(l10n.level(l10n.difficulty('easy'))), findsOneWidget);
  });

  testWidgets('initial -> progress instead of the board', (tester) async {
    await pump(tester, const GameInitial());
    expect(find.byType(BoardView), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets("human's turn -> board and 'your move'", (tester) async {
    await pump(tester, playing(newGame));
    expect(find.byType(BoardView), findsOneWidget);
    expect(find.text(l10n.yourTurn), findsOneWidget);
    expect(find.byKey(const ValueKey('game-outcome')), findsNothing);
  });

  testWidgets('capture pending -> mandatory capture hint', (tester) async {
    await pump(tester, playing(capture));
    expect(find.text(l10n.mustCapture), findsOneWidget);
  });

  testWidgets('computer thinking -> hint with a spinner', (tester) async {
    await pump(tester, playing(newGame, aiThinking: true));
    expect(find.text(l10n.aiThinking), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('tap on the board -> SquareTapped with that square', (
    tester,
  ) async {
    await pump(tester, playing(newGame));
    final rect = tester.getRect(
      find.descendant(
        of: find.byType(BoardView),
        matching: find.byType(CustomPaint),
      ),
    );
    final cell = rect.width / 8;
    await tester.tapAt(rect.topLeft + Offset(2.5 * cell, 5.5 * cell));
    verify(() => bloc.add(SquareTapped(p(5, 2)))).called(1);
  });

  testWidgets('no move made yet -> undo disabled', (tester) async {
    await pump(tester, playing(newGame));
    expect(undo(tester).onPressed, isNull);
    expect(undo(tester).tooltip, l10n.undoMove);
  });

  testWidgets('after a move -> undo sends MoveUndone', (tester) async {
    final afterAi = rules.play(
      rules.play(newGame, Move([p(5, 2), p(4, 3)])),
      rules.play(newGame, Move([p(5, 2), p(4, 3)])).legalMoves.first,
    );
    await pump(tester, playing(afterAi, history: [newGame]));
    await tester.tap(find.byKey(const ValueKey('game-undo')));
    verify(() => bloc.add(const MoveUndone())).called(1);
  });

  testWidgets('computer moved -> its move in notation, announced', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final afterHuman = rules.play(newGame, Move([p(5, 2), p(4, 3)]));
    final reply = afterHuman.legalMoves.first;
    await pump(tester, playing(rules.play(afterHuman, reply)));
    expect(find.text(l10n.computerMoved(reply.notation)), findsOneWidget);
    final status = tester.getSemantics(
      find.ancestor(
        of: find.text(l10n.yourTurn),
        matching: find.byWidgetPredicate(
          (w) => w is Semantics && (w.properties.liveRegion ?? false),
        ),
      ),
    );
    expect(status.flagsCollection.isLiveRegion, isTrue);
    semantics.dispose();
  });

  testWidgets('human plays black -> board flipped, restart keeps the side', (
    tester,
  ) async {
    when(() => bloc.state).thenReturn(playing(newGame));
    await tester.pumpApp(
      BlocProvider<GameBloc>.value(
        value: bloc,
        child: const GamePage(difficulty: easy, humanColor: PieceColor.black),
      ),
    );
    expect(tester.widget<BoardView>(find.byType(BoardView)).flipped, isTrue);
    await tester.tap(find.byKey(const ValueKey('game-restart')));
    verify(
      () => bloc.add(const GameStarted(easy, humanColor: PieceColor.black)),
    ).called(1);
  });

  testWidgets('restart button -> GameStarted', (tester) async {
    await pump(tester, playing(newGame));
    await tester.tap(find.byKey(const ValueKey('game-restart')));
    verify(() => bloc.add(const GameStarted(easy))).called(1);
  });

  testWidgets('game over with stats -> outcome and level stats', (
    tester,
  ) async {
    await pump(
      tester,
      GameOver(
        difficulty: easy,
        game: won,
        outcome: GameOutcome.win,
        levelStats: LevelStats(wins: 2, losses: 1, draws: 3),
      ),
    );
    expect(find.text(l10n.outcome('win')), findsOneWidget);
    expect(
      find.text(
        '${l10n.wins}: 2 · ${l10n.losses}: 1 · ${l10n.draws}: 3',
      ),
      findsOneWidget,
    );
    expect(find.byType(BoardView), findsOneWidget);
  });

  testWidgets('game over before stats are saved -> no stats line', (
    tester,
  ) async {
    await pump(
      tester,
      GameOver(difficulty: easy, game: won, outcome: GameOutcome.loss),
    );
    expect(find.text(l10n.outcome('loss')), findsOneWidget);
    expect(find.byKey(const ValueKey('game-level-stats')), findsNothing);
  });

  testWidgets('stats not saved -> error text', (tester) async {
    await pump(
      tester,
      GameOver(
        difficulty: easy,
        game: won,
        outcome: GameOutcome.draw,
        saveError: const GameResultNotSavedException(),
      ),
    );
    expect(find.text(l10n.outcome('draw')), findsOneWidget);
    expect(find.text(l10n.statsStorageFailed), findsOneWidget);
  });

  testWidgets('play again -> GameStarted', (tester) async {
    await pump(
      tester,
      GameOver(difficulty: easy, game: won, outcome: GameOutcome.win),
    );
    await tester.tap(find.byKey(const ValueKey('game-play-again')));
    verify(() => bloc.add(const GameStarted(easy))).called(1);
  });

  testWidgets('menu -> home', (tester) async {
    await pump(
      tester,
      GameOver(difficulty: easy, game: won, outcome: GameOutcome.win),
    );
    await tester.tap(find.byKey(const ValueKey('game-menu')));
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('failure -> message and retry', (tester) async {
    await pump(
      tester,
      const GameFailure(difficulty: easy, exception: IllegalMoveException()),
    );
    expect(find.text(l10n.illegalMove), findsOneWidget);
    expect(find.byType(BoardView), findsNothing);
    await tester.tap(find.byKey(const ValueKey('game-retry')));
    verify(() => bloc.add(const GameStarted(easy))).called(1);
  });

  testWidgets('accessibility guidelines', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester, playing(newGame));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    semantics.dispose();
  });

  testWidgets('large text (200%) -> no overflow', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pump(tester, playing(newGame));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
