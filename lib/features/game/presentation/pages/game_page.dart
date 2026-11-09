import 'package:checkers_app/core/l10n/l10n.dart';
import 'package:checkers_app/core/widgets/app_page_layout.dart';
import 'package:checkers_app/features/game/domain/game_domain.dart';
import 'package:checkers_app/features/game/presentation/bloc/game/game_bloc.dart';
import 'package:checkers_app/features/game/presentation/bloc/game/game_event.dart';
import 'package:checkers_app/features/game/presentation/pages/widgets/game_body.dart';
import 'package:checkers_app/features/game/presentation/pages/widgets/undo_move_button.dart';
import 'package:checkers_app/features/shared/game_results/difficulty.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    return AppPageLayout(
      title: l10n.level(l10n.difficulty(difficulty.name)),
      maxContentWidth: 560,
      actions: [
        const UndoMoveButton(),
        IconButton(
          key: const ValueKey('game-restart'),
          tooltip: l10n.playAgain,
          icon: const Icon(Icons.refresh),
          onPressed: () => context.read<GameBloc>().add(
            GameStarted(difficulty, humanColor: humanColor),
          ),
        ),
      ],
      body: GameBody(difficulty: difficulty, humanColor: humanColor),
    );
  }
}
