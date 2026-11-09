import 'package:checkers_app/features/game/domain/game_domain.dart';
import 'package:checkers_app/features/game/presentation/bloc/game/game_bloc.dart';
import 'package:checkers_app/features/game/presentation/bloc/game/game_event.dart';
import 'package:checkers_app/features/game/presentation/bloc/game/game_state.dart';
import 'package:checkers_app/features/game/presentation/pages/widgets/board_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({required this.flipped, super.key});

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
