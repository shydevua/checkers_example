import 'package:checkers_app/features/game/domain/value_objects/position.dart';
import 'package:equatable/equatable.dart';

/// A complete move: the squares the piece visits and the pieces it captures.
final class Move extends Equatable {
  /// Throws [ArgumentError] if [path] has fewer than two squares.
  Move(List<Position> path, {List<Position> captured = const []})
    : path = List.unmodifiable(path),
      captured = List.unmodifiable(captured) {
    if (path.length < 2) {
      throw ArgumentError.value(path, 'path', 'needs at least two squares');
    }
  }

  /// Visited squares, from the start square to the final square.
  final List<Position> path;

  /// Squares of captured pieces in capture order.
  final List<Position> captured;

  Position get from => path.first;

  Position get to => path.last;

  bool get isCapture => captured.isNotEmpty;

  /// The move in checkers notation: `c3-d4` for a quiet move, `c3:e5:g7`
  /// for a capture (every landing square).
  String get notation =>
      path.map((square) => square.notation).join(isCapture ? ':' : '-');

  @override
  List<Object?> get props => [path, captured];
}
