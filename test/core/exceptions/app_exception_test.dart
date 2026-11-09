import 'package:checkers_app/core/exceptions/app_exception.dart';
import 'package:flutter_test/flutter_test.dart';

final class _TestException extends AppException {
  const _TestException();
}

void main() {
  test('AppException is an Exception with value equality', () {
    expect(const _TestException(), isA<Exception>());
    expect(const _TestException(), const _TestException());
    expect(const _TestException().props, isEmpty);
  });
}
