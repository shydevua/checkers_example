import 'package:checkers_app/core/usecases/use_case.dart';
import 'package:checkers_app/features/game/domain/value_objects/move_selection.dart';
import 'package:checkers_app/features/game/domain/value_objects/position.dart';
import 'package:equatable/equatable.dart';

final class SelectSquareParams extends Equatable {
  const SelectSquareParams({required this.selection, required this.position});

  final MoveSelection selection;
  final Position position;

  @override
  List<Object?> get props => [selection, position];
}

/// Applies a tap on a square to the current selection:
///
/// * a square that continues the path extends it (the move may complete);
/// * tapping the only selected piece again deselects it;
/// * a piece that can move becomes the new selection;
/// * any other square clears the selection.
class SelectSquare implements UseCase<MoveSelection, SelectSquareParams> {
  const SelectSquare();

  @override
  Future<MoveSelection> call(SelectSquareParams params) async {
    final SelectSquareParams(:selection, :position) = params;
    final moves = selection.legalMoves;
    if (selection.targets.contains(position)) {
      return MoveSelection(moves, path: [...selection.path, position]);
    }
    final reselect = switch (selection.path) {
      [final selected] => selected == position,
      _ => false,
    };
    if (!reselect && selection.movable.contains(position)) {
      return MoveSelection(moves, path: [position]);
    }
    return MoveSelection(moves);
  }
}
