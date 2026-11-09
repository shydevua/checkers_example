import 'package:bloc_test/bloc_test.dart';
import 'package:checkers_app/core/l10n/l10n.dart';
import 'package:checkers_app/core/navigation/app_paths.dart';
import 'package:checkers_app/features/statistics/presentation/bloc/stats/stats_bloc.dart';
import 'package:checkers_app/features/statistics/presentation/bloc/stats/stats_event.dart';
import 'package:checkers_app/features/statistics/presentation/bloc/stats/stats_state.dart';
import 'package:checkers_app/features/statistics/presentation/pages/stats_page.dart';
import 'package:checkers_app/features/statistics/presentation/routes/statistics_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class _MockStatsBloc extends MockBloc<StatsEvent, StatsState>
    implements StatsBloc {}

void main() {
  late _MockStatsBloc bloc;

  setUp(() {
    bloc = _MockStatsBloc();
    when(() => bloc.state).thenReturn(const StatsInitial());
    GetIt.I.registerFactory<StatsBloc>(() => bloc);
  });

  tearDown(GetIt.I.reset);

  test('route is named for analytics', () {
    expect((statisticsRoutes().single as GoRoute).name, AppPaths.statsName);
  });

  testWidgets('stats path -> StatsPage, stats requested', (tester) async {
    final router = GoRouter(
      initialLocation: AppPaths.stats,
      routes: statisticsRoutes(),
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
    expect(find.byType(StatsPage), findsOneWidget);
    verify(() => bloc.add(const StatsRequested())).called(1);
  });
}
