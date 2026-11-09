import 'package:checkers_app/core/storage/key_value_storage.dart';
import 'package:checkers_app/core/storage/storage_exception.dart';
import 'package:checkers_app/features/statistics/data/datasources/local/stats_local_data_source.dart';
import 'package:checkers_app/features/statistics/data/dto/game_stats_dto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mocktail/mocktail.dart';

class _MockKeyValueStorage extends Mock implements KeyValueStorage {}

void main() {
  late _MockKeyValueStorage storage;
  late StatsLocalDataSource sut;
  const key = 'checkers.stats.v1';
  const dto = GameStatsDto(
    easy: LevelStatsDto(wins: 1, losses: 0, draws: 0),
    medium: LevelStatsDto(wins: 0, losses: 2, draws: 0),
    hard: LevelStatsDto(wins: 0, losses: 0, draws: 3),
  );
  const raw =
      '{"easy":{"wins":1,"losses":0,"draws":0},'
      '"medium":{"wins":0,"losses":2,"draws":0},'
      '"hard":{"wins":0,"losses":0,"draws":3}}';

  setUp(() {
    storage = _MockKeyValueStorage();
    sut = StatsLocalDataSource(storage);
  });

  test('storage key', () {
    expect(StatsLocalDataSource.storageKey, key);
  });

  group('read', () {
    test('nothing stored -> null', () async {
      when(() => storage.read(key)).thenAnswer((_) async => null);
      expect(await sut.read(), isNull);
    });

    test('valid JSON -> dto', () async {
      when(() => storage.read(key)).thenAnswer((_) async => raw);
      expect(await sut.read(), dto);
    });

    test('invalid JSON -> FormatException', () async {
      when(() => storage.read(key)).thenAnswer((_) async => '{oops');
      await expectLater(sut.read(), throwsA(isA<FormatException>()));
    });

    test('JSON that is not an object -> FormatException', () async {
      when(() => storage.read(key)).thenAnswer((_) async => '[1, 2]');
      await expectLater(
        sut.read(),
        throwsA(
          const FormatException('Stats payload is not a JSON object'),
        ),
      );
    });

    test('object with wrong schema -> CheckedFromJsonException', () async {
      when(() => storage.read(key)).thenAnswer((_) async => '{"easy": 1}');
      await expectLater(
        sut.read(),
        throwsA(isA<CheckedFromJsonException>()),
      );
    });

    test('StorageException -> propagates', () async {
      when(() => storage.read(key)).thenThrow(const StorageException('x'));
      await expectLater(sut.read(), throwsA(const StorageException('x')));
    });
  });

  group('write', () {
    test('stores the JSON under the key', () async {
      when(() => storage.write(key, raw)).thenAnswer((_) async {});
      await sut.write(dto);
      verify(() => storage.write(key, raw)).called(1);
    });

    test('StorageException -> propagates', () async {
      when(
        () => storage.write(key, raw),
      ).thenThrow(const StorageException('x'));
      await expectLater(sut.write(dto), throwsA(const StorageException('x')));
    });
  });

  group('delete', () {
    test('removes the key', () async {
      when(() => storage.delete(key)).thenAnswer((_) async {});
      await sut.delete();
      verify(() => storage.delete(key)).called(1);
    });

    test('StorageException -> propagates', () async {
      when(() => storage.delete(key)).thenThrow(const StorageException('x'));
      await expectLater(sut.delete(), throwsA(const StorageException('x')));
    });
  });
}
