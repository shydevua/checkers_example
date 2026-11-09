import 'package:checkers_app/core/exceptions/app_exception.dart';
import 'package:checkers_app/features/game/domain/game_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('exceptions are AppExceptions compared by value', () {
    expect(const IllegalMoveException(), isA<AppException>());
    expect(
      const InvalidPositionException(1, 2),
      const InvalidPositionException(1, 2),
    );
    expect(
      const InvalidPositionException(1, 2),
      isNot(const InvalidPositionException(2, 1)),
    );
    expect(
      const IllegalMoveException(),
      isNot(const GameAlreadyOverException()),
    );
  });
}
