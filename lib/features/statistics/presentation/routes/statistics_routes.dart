import 'package:checkers_app/core/navigation/app_paths.dart';
import 'package:checkers_app/features/statistics/presentation/bloc/stats/stats_bloc.dart';
import 'package:checkers_app/features/statistics/presentation/bloc/stats/stats_event.dart';
import 'package:checkers_app/features/statistics/presentation/pages/stats_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

List<RouteBase> statisticsRoutes() => [
  GoRoute(
    path: AppPaths.stats,
    name: AppPaths.statsName,
    builder: (_, _) => BlocProvider(
      create: (_) => GetIt.I<StatsBloc>()..add(const StatsRequested()),
      child: const StatsPage(),
    ),
  ),
];
