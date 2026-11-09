import 'package:checkers_app/core/l10n/l10n.dart';
import 'package:checkers_app/features/game/presentation/bloc/game/game_bloc.dart';
import 'package:checkers_app/features/game/presentation/bloc/game/game_event.dart';
import 'package:checkers_app/features/game/presentation/bloc/game/game_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UndoMoveButton extends StatelessWidget {
  const UndoMoveButton({super.key});

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
