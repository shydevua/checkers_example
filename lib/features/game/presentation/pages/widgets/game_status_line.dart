import 'package:checkers_app/core/l10n/l10n.dart';
import 'package:checkers_app/core/theme/app_spacing.dart';
import 'package:checkers_app/features/game/presentation/bloc/game/game_bloc.dart';
import 'package:checkers_app/features/game/presentation/bloc/game/game_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum _Status { yourTurn, mustCapture, aiThinking }

/// Whose turn it is and the computer's last move. A live region, so screen
/// readers announce every change without the user looking for it.
class GameStatusLine extends StatelessWidget {
  const GameStatusLine({super.key});

  @override
  Widget build(BuildContext context) {
    final (status, computerMove) = context
        .select<GameBloc, (_Status?, String?)>(
          (bloc) => switch (bloc.state) {
            GameInProgress(aiThinking: true) => (_Status.aiThinking, null),
            GameInProgress(:final game) => (
              game.mustCapture ? _Status.mustCapture : _Status.yourTurn,
              game.lastMove?.notation,
            ),
            _ => (null, null),
          },
        );
    if (status == null) return const SizedBox(height: 48);
    final l10n = context.l10n;
    final text = switch (status) {
      _Status.yourTurn => l10n.yourTurn,
      _Status.mustCapture => l10n.mustCapture,
      _Status.aiThinking => l10n.aiThinking,
    };
    final theme = Theme.of(context).textTheme;
    return Semantics(
      liveRegion: true,
      container: true,
      // Minimum, not fixed, height: large text must not be clipped.
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (status == _Status.aiThinking) ...const [
                  SizedBox.square(
                    dimension: 16,
                    child: RepaintBoundary(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  SizedBox(width: AppSpacing.s),
                ],
                Text(text, style: theme.titleMedium),
              ],
            ),
            if (computerMove != null)
              Text(
                l10n.computerMoved(computerMove),
                key: const ValueKey('game-computer-move'),
                style: theme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }
}
