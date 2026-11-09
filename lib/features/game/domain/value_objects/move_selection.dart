import 'package:checkers_app/features/game/domain/entities/move.dart';
import 'package:checkers_app/features/game/domain/value_objects/position.dart';
import 'package:equatable/equatable.dart';

/// What the human player has selected so far while building a move square
/// by square. All derived sets are computed once, so the UI only reads them.
final class MoveSelection extends Equatable {
  /// Throws [ArgumentError] if no legal move starts with [path].
  factory MoveSelection(
    List<Move> legalMoves, {
    List<Position> path = const [],
  }) {
    final candidates = [
      for (final move in legalMoves)
        if (_startsWith(move.path, path)) move,
    ];
    if (path.isNotEmpty && candidates.isEmpty) {
      throw ArgumentError.value(
        path,
        'path',
        'is not a prefix of a legal move',
      );
    }
    return MoveSelection._(
      legalMoves: List.unmodifiable(legalMoves),
      path: List.unmodifiable(path),
      movable: Set.unmodifiable({for (final move in legalMoves) move.from}),
      targets: Set.unmodifiable({
        if (path.isNotEmpty)
          for (final move in candidates)
            if (move.path.length > path.length) move.path[path.length],
      }),
      completedMove: _withLength(candidates, path.length),
    );
  }

  const MoveSelection._({
    required this.legalMoves,
    required this.path,
    required this.movable,
    required this.targets,
    required this.completedMove,
  });

  /// Nothing selected and nothing to select.
  static const none = MoveSelection._(
    legalMoves: [],
    path: [],
    movable: {},
    targets: {},
    completedMove: null,
  );

  final List<Move> legalMoves;

  /// Squares chosen so far; the first one is the selected piece.
  final List<Position> path;

  /// Squares of pieces that have a legal move.
  final Set<Position> movable;

  /// Squares that continue the current [path].
  final Set<Position> targets;

  /// The legal move equal to [path], once the path is complete.
  final Move? completedMove;

  /// Square where the selected piece currently is in the selection.
  Position? get current => path.isEmpty ? null : path.last;

  static Move? _withLength(List<Move> moves, int length) {
    for (final move in moves) {
      if (move.path.length == length) return move;
    }
    return null;
  }

  static bool _startsWith(List<Position> path, List<Position> prefix) {
    if (prefix.length > path.length) return false;
    for (var i = 0; i < prefix.length; i++) {
      if (path[i] != prefix[i]) return false;
    }
    return true;
  }

  @override
  List<Object?> get props => [legalMoves, path];
}
