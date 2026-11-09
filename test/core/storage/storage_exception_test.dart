import 'package:checkers_app/core/storage/storage_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('equality by message', () {
    expect(const StorageException('a'), const StorageException('a'));
    expect(const StorageException('a'), isNot(const StorageException('b')));
    expect(const StorageException('a').message, 'a');
  });
}
