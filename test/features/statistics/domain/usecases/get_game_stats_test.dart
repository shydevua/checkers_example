import 'package:checkers_app/core/usecases/use_case.dart';
import 'package:checkers_app/features/shared/game_results/level_stats.dart';
import 'package:checkers_app/features/statistics/domain/statistics_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockStatsRepository extends Mock implements StatsRepository {}

void main() {
  late _MockStatsRepository repository;
  late GetGameStats sut;
  final stats = GameStats(easy: LevelStats(wins: 2));

  setUp(() {
    repository = _MockStatsRepository();
    sut = GetGameStats(repository);
  });

  test('returns the stored stats', () async {
    when(() => repository.load()).thenAnswer((_) async => stats);
    expect(await sut(const NoParams()), stats);
    verify(() => repository.load()).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('StatsStorageException -> propagates', () async {
    when(() => repository.load()).thenThrow(const StatsStorageException());
    await expectLater(
      sut(const NoParams()),
      throwsA(const StatsStorageException()),
    );
  });

  test('StatsCorruptedException -> propagates', () async {
    when(() => repository.load()).thenThrow(const StatsCorruptedException());
    await expectLater(
      sut(const NoParams()),
      throwsA(const StatsCorruptedException()),
    );
  });
}
