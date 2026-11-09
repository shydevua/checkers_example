import 'package:checkers_app/app/observers/screen_view_observer.dart';
import 'package:checkers_app/core/analytics/analytics.dart';
import 'package:checkers_app/core/navigation/app_paths.dart';
import 'package:checkers_app/features/game/presentation/routes/game_routes.dart';
import 'package:checkers_app/features/menu/presentation/routes/menu_routes.dart';
import 'package:checkers_app/features/statistics/presentation/routes/statistics_routes.dart';
import 'package:go_router/go_router.dart';

/// Composes the routes of every feature.
GoRouter createAppRouter({required Analytics analytics}) => GoRouter(
  initialLocation: AppPaths.home,
  observers: [ScreenViewObserver(analytics)],
  routes: [...menuRoutes(), ...gameRoutes(), ...statisticsRoutes()],
);
