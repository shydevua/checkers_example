import 'package:checkers_app/core/l10n/l10n.dart';
import 'package:checkers_app/core/navigation/app_paths.dart';
import 'package:checkers_app/core/theme/app_spacing.dart';
import 'package:checkers_app/core/widgets/app_button.dart';
import 'package:checkers_app/features/game/domain/game_domain.dart';
import 'package:checkers_app/features/game/presentation/bloc/game/game_bloc.dart';
import 'package:checkers_app/features/game/presentation/bloc/game/game_event.dart';
import 'package:checkers_app/features/game/presentation/bloc/game/game_state.dart';
import 'package:checkers_app/features/game/presentation/widgets/board_view.dart';
import 'package:checkers_app/features/game/presentation/widgets/game_error_text.dart';
import 'package:checkers_app/features/shared/game_results/difficulty.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class GamePage extends StatelessWidget {
  const GamePage({
    required this.difficulty,
    this.humanColor = PieceColor.white,
    super.key,
  });

  final Difficulty difficulty;
  final PieceColor humanColor;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.level(l10n.difficulty(difficulty.name))),
        actions: [
          const _UndoButton(),
          IconButton(
            key: const ValueKey('game-restart'),
            tooltip: l10n.playAgain,
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<GameBloc>().add(
              GameStarted(difficulty, humanColor: humanColor),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _GameBody(difficulty: difficulty, humanColor: humanColor),
      ),
    );
  }
}

class _UndoButton extends StatelessWidget {
  const _UndoButton();

  @override
  Widget build(BuildContext context) {
    final canUndo = context.select<GameBloc, bool>(
      (bloc) => switch (bloc.state) {
        final GameInProgress state => state.canUndo,
        _ => false,
      },
    );
    return IconButton(
      key: const ValueKey('game-undo'),
      tooltip: context.l10n.undoMove,
      icon: const Icon(Icons.undo),
      onPressed: canUndo
          ? () => context.read<GameBloc>().add(const MoveUndone())
          : null,
    );
  }
}

class _GameBody extends StatelessWidget {
  const _GameBody({required this.difficulty, required this.humanColor});

  final Difficulty difficulty;
  final PieceColor humanColor;

  @override
  Widget build(BuildContext context) {
    final failure = context.select<GameBloc, GameException?>(
      (bloc) => switch (bloc.state) {
        GameFailure(:final exception) => exception,
        _ => null,
      },
    );
    if (failure != null) {
      return _FailureView(
        difficulty: difficulty,
        humanColor: humanColor,
        exception: failure,
      );
    }
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.m),
          children: [
            const _StatusLine(),
            const SizedBox(height: AppSpacing.m),
            _Board(flipped: humanColor == PieceColor.black),
            const SizedBox(height: AppSpacing.m),
            const _GameOverPanel(),
          ],
        ),
      ),
    );
  }
}

enum _Status { yourTurn, mustCapture, aiThinking }

/// Whose turn it is and the computer's last move. A live region, so screen
/// readers announce every change without the user looking for it.
class _StatusLine extends StatelessWidget {
  const _StatusLine();

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

class _Board extends StatelessWidget {
  const _Board({required this.flipped});

  final bool flipped;

  @override
  Widget build(BuildContext context) {
    final data = context.select<GameBloc, (Board, MoveSelection, Move?)?>(
      (bloc) => switch (bloc.state) {
        GameInProgress(:final game, :final selection) => (
          game.board,
          selection,
          game.lastMove,
        ),
        GameOver(:final game) => (
          game.board,
          MoveSelection.none,
          game.lastMove,
        ),
        GameInitial() || GameFailure() => null,
      },
    );
    if (data == null) {
      return const AspectRatio(
        aspectRatio: 1,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final (board, selection, lastMove) = data;
    return BoardView(
      key: const ValueKey('game-board'),
      board: board,
      selection: selection,
      lastMove: lastMove,
      flipped: flipped,
      onSquareTap: (position) =>
          context.read<GameBloc>().add(SquareTapped(position)),
    );
  }
}

class _GameOverPanel extends StatelessWidget {
  const _GameOverPanel();

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

class _FailureView extends StatelessWidget {
  const _FailureView({
    required this.difficulty,
    required this.humanColor,
    required this.exception,
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
