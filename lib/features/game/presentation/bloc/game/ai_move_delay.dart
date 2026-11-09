/// Minimum time the computer "thinks", so the human sees their own move
/// before the reply appears.
final class AiMoveDelay {
  const AiMoveDelay(this.duration);

  final Duration duration;
}
