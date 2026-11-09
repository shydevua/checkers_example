import 'package:checkers_app/core/usecases/use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('NoParams instances are equal', () {
    expect(const NoParams(), const NoParams());
    expect(const NoParams().props, isEmpty);
  });
}
