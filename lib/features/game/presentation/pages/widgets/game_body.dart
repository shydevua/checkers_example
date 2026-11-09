import 'package:checkers_app/core/theme/app_spacing.dart';
import 'package:checkers_app/features/game/domain/game_domain.dart';
import 'package:checkers_app/features/game/presentation/bloc/game/game_bloc.dart';
import 'package:checkers_app/features/game/presentation/bloc/game/game_state.dart';
import 'package:checkers_app/features/game/presentation/pages/widgets/game_board.dart';
import 'package:checkers_app/features/game/presentation/pages/widgets/game_failure_view.dart';
import 'package:checkers_app/features/game/presentation/pages/widgets/game_over_panel.dart';
import 'package:checkers_app/features/game/presentation/pages/widgets/game_status_line.dart';
import 'package:checkers_app/features/shared/game_results/difficulty.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GameBody extends StatelessWidget {
  const GameBody({
    required this.difficulty,
    required this.humanColor,
    super.key,
  });

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
      return GameFailureView(
        difficulty: difficulty,
        humanColor: humanColor,
        exception: failure,
      );
    }
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.m),
      children: [
        const GameStatusLine(),
        const SizedBox(height: AppSpacing.m),
        GameBoard(flipped: humanColor == PieceColor.black),
        const SizedBox(height: AppSpacing.m),
        const GameOverPanel(),
      ],
    );
  }
}
