import 'package:bloc_test/bloc_test.dart';
import 'package:checkers_app/features/shared/game_results/level_stats.dart';
import 'package:checkers_app/features/statistics/domain/statistics_domain.dart';
import 'package:checkers_app/features/statistics/presentation/bloc/stats/stats_bloc.dart';
import 'package:checkers_app/features/statistics/presentation/bloc/stats/stats_event.dart';
import 'package:checkers_app/features/statistics/presentation/bloc/stats/stats_state.dart';
import 'package:checkers_app/features/statistics/presentation/pages/stats_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/pump_app.dart';

class _MockStatsBloc extends MockBloc<StatsEvent, StatsState>
    implements StatsBloc {}

void main() {
  late _MockStatsBloc bloc;

  setUp(() => bloc = _MockStatsBloc());

  Future<void> pump(WidgetTester tester, StatsState state) async {
    when(() => bloc.state).thenReturn(state);
    await tester.pumpApp(
      BlocProvider<StatsBloc>.value(value: bloc, child: const StatsPage()),
    );
  }

  IconButton reset(WidgetTester tester) =>
      tester.widget<IconButton>(find.byKey(const ValueKey('stats-reset')));

  testWidgets('loading -> spinner, reset disabled', (tester) async {
    await pump(tester, const StatsLoadInProgress());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(reset(tester).onPressed, isNull);
  });

  testWidgets('initial -> spinner', (tester) async {
    await pump(tester, const StatsInitial());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('loaded -> one row per level with its counters', (tester) async {
    await pump(
      tester,
      StatsLoaded(
        GameStats(
          easy: LevelStats(wins: 1, losses: 2, draws: 3),
          medium: LevelStats(wins: 4, losses: 5, draws: 6),
          hard: LevelStats(wins: 7, losses: 8, draws: 9),
        ),
      ),
    );
    expect(find.text(l10n.difficulty('easy')), findsOneWidget);
    expect(find.text(l10n.difficulty('medium')), findsOneWidget);
    expect(find.text(l10n.difficulty('hard')), findsOneWidget);
    for (final n in ['1', '2', '3', '4', '5', '6', '7', '8', '9']) {
      expect(find.text(n), findsOneWidget);
    }
  });

  testWidgets('loaded -> reset sends StatsResetRequested', (tester) async {
    await pump(tester, const StatsLoaded(GameStats.empty));
    await tester.tap(find.byKey(const ValueKey('stats-reset')));
    verify(() => bloc.add(const StatsResetRequested())).called(1);
  });

  testWidgets('failure -> message, retry sends StatsRequested', (tester) async {
    await pump(tester, const StatsFailure(StatsCorruptedException()));
    expect(find.text(l10n.statsCorrupted), findsOneWidget);
    expect(reset(tester).onPressed, isNull);
    await tester.tap(find.byKey(const ValueKey('stats-retry')));
    verify(() => bloc.add(const StatsRequested())).called(1);
  });

  testWidgets('accessibility guidelines', (tester) async {
    final semantics = tester.ensureSemantics();
    await pump(tester, const StatsLoaded(GameStats.empty));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    semantics.dispose();
  });

  testWidgets('large text (200%) -> no overflow', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pump(tester, const StatsLoaded(GameStats.empty));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
