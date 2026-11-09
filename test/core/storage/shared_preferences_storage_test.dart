import 'package:checkers_app/core/storage/shared_preferences_storage.dart';
import 'package:checkers_app/core/storage/storage_exception.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockPreferences extends Mock implements SharedPreferencesAsync {}

void main() {
  late _MockPreferences preferences;
  late SharedPreferencesStorage sut;
  final failure = PlatformException(code: 'io', message: 'disk full');
  const expected = StorageException('io: disk full');

  setUp(() {
    preferences = _MockPreferences();
    sut = SharedPreferencesStorage(preferences);
  });

  group('read', () {
    test('stored value -> value', () async {
      when(() => preferences.getString('k')).thenAnswer((_) async => 'v');
      expect(await sut.read('k'), 'v');
    });

    test('missing value -> null', () async {
      when(() => preferences.getString('k')).thenAnswer((_) async => null);
      expect(await sut.read('k'), isNull);
    });

    test('PlatformException -> StorageException', () async {
      when(() => preferences.getString('k')).thenThrow(failure);
      await expectLater(sut.read('k'), throwsA(expected));
    });
  });

  group('write', () {
    test('stores the value', () async {
      when(() => preferences.setString('k', 'v')).thenAnswer((_) async {});
      await sut.write('k', 'v');
      verify(() => preferences.setString('k', 'v')).called(1);
    });

    test('PlatformException -> StorageException', () async {
      when(() => preferences.setString('k', 'v')).thenThrow(failure);
      await expectLater(sut.write('k', 'v'), throwsA(expected));
    });
  });

  group('delete', () {
    test('removes the key', () async {
      when(() => preferences.remove('k')).thenAnswer((_) async {});
      await sut.delete('k');
      verify(() => preferences.remove('k')).called(1);
    });

    test('PlatformException -> StorageException', () async {
      when(() => preferences.remove('k')).thenThrow(failure);
      await expectLater(sut.delete('k'), throwsA(expected));
    });
  });
}
