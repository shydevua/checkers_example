import 'package:checkers_app/app/di/environment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('no ENV define -> dev', () {
    expect(rawEnvironment, 'dev');
  });

  test('dev and prod -> accepted as is', () {
    expect(parseEnvironment('dev'), 'dev');
    expect(parseEnvironment('prod'), 'prod');
  });

  test('anything else -> ArgumentError naming ENV', () {
    expect(
      () => parseEnvironment('staging'),
      throwsA(
        isA<ArgumentError>()
            .having((e) => e.name, 'name', 'ENV')
            .having((e) => e.invalidValue, 'value', 'staging'),
      ),
    );
  });
}
