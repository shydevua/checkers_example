import 'package:checkers_app/core/l10n/l10n.dart';
import 'package:checkers_app/core/navigation/app_paths.dart';
import 'package:checkers_app/core/theme/app_spacing.dart';
import 'package:checkers_app/core/widgets/app_button.dart';
import 'package:checkers_app/features/game/presentation/bloc/game/game_bloc.dart';
import 'package:checkers_app/features/game/presentation/bloc/game/game_event.dart';
import 'package:checkers_app/features/game/presentation/bloc/game/game_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class GameOverPanel extends StatelessWidget {
  const GameOverPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final over = context.select<GameBloc, GameOver?>(
      (bloc) => switch (bloc.state) {
        final GameOver state => state,
        _ => null,
      },
    );
    if (over == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    final level = over.levelStats;
    final error = over.saveError;
    return Column(
      children: [
        Semantics(
          liveRegion: true,
          child: Text(
            l10n.outcome(over.outcome.name),
            key: const ValueKey('game-outcome'),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        if (level != null) ...[
          const SizedBox(height: AppSpacing.s),
          Text(
            '${l10n.wins}: ${level.wins} · ${l10n.losses}: ${level.losses}'
            ' · ${l10n.draws}: ${level.draws}',
            key: const ValueKey('game-level-stats'),
          ),
        ],
        if (error != null) ...[
          const SizedBox(height: AppSpacing.s),
          Text(
            l10n.statsStorageFailed,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: AppSpacing.m),
        AppButton(
          key: const ValueKey('game-play-again'),
          label: l10n.playAgain,
          onPressed: () => context.read<GameBloc>().add(
            GameStarted(over.difficulty, humanColor: over.humanColor),
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        TextButton(
          key: const ValueKey('game-menu'),
          onPressed: () => context.go(AppPaths.home),
          child: Text(l10n.backToMenu),
        ),
      ],
    );
  }
}
