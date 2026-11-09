import 'package:checkers_app/core/exceptions/app_exception.dart';
import 'package:checkers_app/features/shared/game_results/game_result_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('exceptions are AppExceptions compared by type', () {
    expect(const GameResultNotSavedException(), isA<AppException>());
    expect(
      const GameResultNotSavedException(),
      const GameResultNotSavedException(),
    );
    expect(
      const GameResultNotSavedException(),
      isNot(const InvalidLevelStatsException()),
    );
  });
}
