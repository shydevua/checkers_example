import 'package:checkers_app/core/navigation/app_paths.dart';
import 'package:checkers_app/features/menu/presentation/pages/home_page.dart';
import 'package:go_router/go_router.dart';

List<RouteBase> menuRoutes() => [
  GoRoute(
    path: AppPaths.home,
    name: AppPaths.homeName,
    builder: (_, _) => const HomePage(),
  ),
];
