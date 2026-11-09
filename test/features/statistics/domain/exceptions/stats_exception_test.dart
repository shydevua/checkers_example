import 'package:checkers_app/core/exceptions/app_exception.dart';
import 'package:checkers_app/features/statistics/domain/statistics_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('exceptions are AppExceptions compared by type', () {
    expect(const StatsStorageException(), isA<AppException>());
    expect(const StatsStorageException(), const StatsStorageException());
    expect(
      const StatsStorageException(),
      isNot(const StatsCorruptedException()),
    );
  });
}
