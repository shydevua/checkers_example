import 'package:checkers_app/features/game/domain/game_domain.dart';

/// How long the computer waits before its reply appears: the human's move
/// first plays out on the board (one [perStep] per square of its path),
/// then a short [pause], so the reply never cuts the animation.
final class AiMoveDelay {
  const AiMoveDelay({required this.pause, this.perStep = Duration.zero});

  final Duration pause;

  /// Time the board needs to animate one square of a move's path.
  final Duration perStep;

  /// Wait before answering [lastMove] (`null` when the computer opens).
  Duration after(Move? lastMove) {
    final steps = lastMove == null ? 0 : lastMove.path.length - 1;
    return perStep * steps + pause;
  }
}
