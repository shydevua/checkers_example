import 'package:checkers_app/core/l10n/l10n.dart';
import 'package:checkers_app/core/theme/app_spacing.dart';
import 'package:checkers_app/core/widgets/app_button.dart';
import 'package:checkers_app/features/game/domain/game_domain.dart';
import 'package:checkers_app/features/game/presentation/bloc/game/game_bloc.dart';
import 'package:checkers_app/features/game/presentation/bloc/game/game_event.dart';
import 'package:checkers_app/features/game/presentation/pages/widgets/game_error_text.dart';
import 'package:checkers_app/features/shared/game_results/difficulty.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GameFailureView extends StatelessWidget {
  const GameFailureView({
    required this.difficulty,
    required this.humanColor,
    required this.exception,
    super.key,
  });

  final Difficulty difficulty;
  final PieceColor humanColor;
  final GameException exception;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              liveRegion: true,
              child: Text(
                gameErrorText(l10n, exception),
                key: const ValueKey('game-error'),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            AppButton(
              key: const ValueKey('game-retry'),
              label: l10n.retry,
              onPressed: () => context.read<GameBloc>().add(
                GameStarted(difficulty, humanColor: humanColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
