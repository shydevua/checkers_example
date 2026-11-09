import 'package:checkers_app/core/storage/storage_exception.dart';
import 'package:checkers_app/features/shared/game_results/level_stats.dart';
import 'package:checkers_app/features/statistics/data/datasources/local/stats_local_data_source.dart';
import 'package:checkers_app/features/statistics/data/dto/game_stats_dto.dart';
import 'package:checkers_app/features/statistics/data/repositories/stats_repository_impl.dart';
import 'package:checkers_app/features/statistics/domain/statistics_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mocktail/mocktail.dart';

class _MockStatsLocalDataSource extends Mock implements StatsLocalDataSource {}

void main() {
  late _MockStatsLocalDataSource local;
  late StatsRepositoryImpl sut;
  const dto = GameStatsDto(
    easy: LevelStatsDto(wins: 1, losses: 0, draws: 0),
    medium: LevelStatsDto(wins: 0, losses: 2, draws: 0),
    hard: LevelStatsDto(wins: 0, losses: 0, draws: 3),
  );
  final stats = GameStats(
    easy: LevelStats(wins: 1),
    medium: LevelStats(losses: 2),
    hard: LevelStats(draws: 3),
  );

  setUp(() {
    local = _MockStatsLocalDataSource();
    sut = StatsRepositoryImpl(local);
  });

  group('load', () {
    test('stored dto -> domain stats', () async {
      when(() => local.read()).thenAnswer((_) async => dto);
      expect(await sut.load(), stats);
    });

    test('nothing stored -> empty stats', () async {
      when(() => local.read()).thenAnswer((_) async => null);
      expect(await sut.load(), GameStats.empty);
    });

    test('StorageException -> StatsStorageException', () async {
      when(() => local.read()).thenThrow(const StorageException('x'));
      await expectLater(sut.load(), throwsA(const StatsStorageException()));
    });

    test('FormatException -> StatsCorruptedException', () async {
      when(() => local.read()).thenThrow(const FormatException('x'));
      await expectLater(sut.load(), throwsA(const StatsCorruptedException()));
    });

    test('CheckedFromJsonException -> StatsCorruptedException', () async {
      when(() => local.read()).thenThrow(
        CheckedFromJsonException(const {}, 'easy', 'GameStatsDto', 'bad'),
      );
      await expectLater(sut.load(), throwsA(const StatsCorruptedException()));
    });

    test('negative counters -> StatsCorruptedException', () async {
      when(() => local.read()).thenAnswer(
        (_) async => const GameStatsDto(
          easy: LevelStatsDto(wins: -1, losses: 0, draws: 0),
          medium: LevelStatsDto(wins: 0, losses: 0, draws: 0),
          hard: LevelStatsDto(wins: 0, losses: 0, draws: 0),
        ),
      );
      await expectLater(sut.load(), throwsA(const StatsCorruptedException()));
    });

    test('translated exception keeps the original stack trace', () async {
      final original = StackTrace.current;
      when(() => local.read()).thenAnswer(
        (_) => Future.error(const StorageException('x'), original),
      );
      Object? caught;
      StackTrace? trace;
      try {
        await sut.load();
      } on StatsStorageException catch (e, st) {
        caught = e;
        trace = st;
      }
      expect(caught, const StatsStorageException());
      expect(trace.toString(), original.toString());
    });
  });

  group('save', () {
    test('writes the dto', () async {
      when(() => local.write(dto)).thenAnswer((_) async {});
      await sut.save(stats);
      verify(() => local.write(dto)).called(1);
    });

    test('StorageException -> StatsStorageException', () async {
      when(() => local.write(dto)).thenThrow(const StorageException('x'));
      await expectLater(
        sut.save(stats),
        throwsA(const StatsStorageException()),
      );
    });
  });

  group('clear', () {
    test('deletes stored stats', () async {
      when(() => local.delete()).thenAnswer((_) async {});
      await sut.clear();
      verify(() => local.delete()).called(1);
    });

    test('StorageException -> StatsStorageException', () async {
      when(() => local.delete()).thenThrow(const StorageException('x'));
      await expectLater(sut.clear(), throwsA(const StatsStorageException()));
    });
  });
}
