import 'package:checkers_app/features/game/domain/game_domain.dart';
import 'package:checkers_app/features/game/presentation/bloc/game/ai_move_delay.dart';
import 'package:flutter_test/flutter_test.dart';

Position p(int row, int col) => Position(row, col);

void main() {
  const delay = AiMoveDelay(
    pause: Duration(milliseconds: 200),
    perStep: Duration(milliseconds: 250),
  );

  test('computer opens -> only the pause', () {
    expect(delay.after(null), const Duration(milliseconds: 200));
  });

  test('quiet move -> one step of animation, then the pause', () {
    expect(
      delay.after(Move([p(5, 2), p(4, 3)])),
      const Duration(milliseconds: 450),
    );
  });

  test('double capture -> two steps of animation, then the pause', () {
    final capture = Move(
      [p(5, 2), p(3, 4), p(1, 6)],
      captured: [p(4, 3), p(2, 5)],
    );
    expect(delay.after(capture), const Duration(milliseconds: 700));
  });

  test('no per-step time -> the pause alone', () {
    expect(
      const AiMoveDelay(pause: Duration(milliseconds: 80)).after(
        Move([p(5, 2), p(4, 3)]),
      ),
      const Duration(milliseconds: 80),
    );
  });
}
