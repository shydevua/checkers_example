import 'package:checkers_app/core/navigation/app_paths.dart';
import 'package:checkers_app/features/game/domain/game_domain.dart';
import 'package:checkers_app/features/game/presentation/bloc/game/game_bloc.dart';
import 'package:checkers_app/features/game/presentation/bloc/game/game_event.dart';
import 'package:checkers_app/features/game/presentation/pages/game_page.dart';
import 'package:checkers_app/features/shared/game_results/difficulty.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

List<RouteBase> gameRoutes() => [
  GoRoute(
    path: AppPaths.game,
    name: AppPaths.gameName,
    redirect: (_, state) =>
        parseDifficulty(_difficultyOf(state)) == null ? AppPaths.home : null,
    builder: (_, state) {
      final difficulty = parseDifficulty(_difficultyOf(state))!;
      final color = parseColor(state.uri.queryParameters[AppPaths.colorParam]);
      return BlocProvider(
        create: (_) =>
            GetIt.I<GameBloc>()
              ..add(GameStarted(difficulty, humanColor: color)),
        child: GamePage(difficulty: difficulty, humanColor: color),
      );
    },
  ),
];

/// The level named [raw] in a path, or `null` for an unknown name.
Difficulty? parseDifficulty(String? raw) => Difficulty.values.asNameMap()[raw];

/// The side named [raw]; white when missing or unknown.
PieceColor parseColor(String? raw) =>
    PieceColor.values.asNameMap()[raw] ?? PieceColor.white;

String? _difficultyOf(GoRouterState state) =>
    state.pathParameters[AppPaths.difficultyParam];
