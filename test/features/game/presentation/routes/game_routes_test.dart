import 'package:bloc_test/bloc_test.dart';
import 'package:checkers_app/core/l10n/l10n.dart';
import 'package:checkers_app/core/navigation/app_paths.dart';
import 'package:checkers_app/features/game/domain/game_domain.dart';
import 'package:checkers_app/features/game/presentation/bloc/game/game_bloc.dart';
import 'package:checkers_app/features/game/presentation/bloc/game/game_event.dart';
import 'package:checkers_app/features/game/presentation/bloc/game/game_state.dart';
import 'package:checkers_app/features/game/presentation/pages/game_page.dart';
import 'package:checkers_app/features/game/presentation/routes/game_routes.dart';
import 'package:checkers_app/features/shared/game_results/difficulty.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class _MockGameBloc extends MockBloc<GameEvent, GameState>
    implements GameBloc {}

void main() {
  group('parseDifficulty', () {
    test('known names -> level', () {
      expect(parseDifficulty('easy'), Difficulty.easy);
      expect(parseDifficulty('medium'), Difficulty.medium);
      expect(parseDifficulty('hard'), Difficulty.hard);
    });

    test('unknown or missing name -> null', () {
      expect(parseDifficulty('expert'), isNull);
      expect(parseDifficulty(null), isNull);
    });
  });

  group('parseColor', () {
    test('known sides -> that side', () {
      expect(parseColor('white'), PieceColor.white);
      expect(parseColor('black'), PieceColor.black);
    });

    test('missing or unknown -> white', () {
      expect(parseColor(null), PieceColor.white);
      expect(parseColor('red'), PieceColor.white);
    });
  });

  test('route is named for analytics', () {
    expect((gameRoutes().single as GoRoute).name, AppPaths.gameName);
  });

  // Routes are the only place that uses GetIt, so route tests are the only
  // ones that register fakes in it.
  group('routes', () {
    late _MockGameBloc bloc;

    setUp(() {
      bloc = _MockGameBloc();
      when(() => bloc.state).thenReturn(const GameInitial());
      GetIt.I.registerFactory<GameBloc>(() => bloc);
    });

    tearDown(GetIt.I.reset);

    Future<void> open(WidgetTester tester, String location) async {
      final router = GoRouter(
        initialLocation: location,
        routes: [
          ...gameRoutes(),
          GoRoute(path: AppPaths.home, builder: (_, _) => const Text('home')),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );
      await tester.pump();
    }

    testWidgets('game path -> GamePage, game started at that level', (
      tester,
    ) async {
      await open(tester, AppPaths.gameFor('hard'));
      expect(
        tester.widget<GamePage>(find.byType(GamePage)).difficulty,
        Difficulty.hard,
      );
      verify(() => bloc.add(const GameStarted(Difficulty.hard))).called(1);
    });

    testWidgets('color query -> game started for that side', (tester) async {
      await open(tester, AppPaths.gameFor('easy', color: 'black'));
      expect(
        tester.widget<GamePage>(find.byType(GamePage)).humanColor,
        PieceColor.black,
      );
      verify(
        () => bloc.add(
          const GameStarted(Difficulty.easy, humanColor: PieceColor.black),
        ),
      ).called(1);
    });

    testWidgets('unknown level -> redirected home', (tester) async {
      await open(tester, AppPaths.gameFor('expert'));
      expect(find.text('home'), findsOneWidget);
      expect(find.byType(GamePage), findsNothing);
    });
  });
}
