import 'package:checkers_app/core/usecases/use_case.dart';
import 'package:checkers_app/features/statistics/domain/statistics_domain.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockStatsRepository extends Mock implements StatsRepository {}

void main() {
  late _MockStatsRepository repository;
  late ResetGameStats sut;

  setUp(() {
    repository = _MockStatsRepository();
    sut = ResetGameStats(repository);
  });

  test('clears storage and returns empty stats', () async {
    when(() => repository.clear()).thenAnswer((_) async {});
    expect(await sut(const NoParams()), GameStats.empty);
    verify(() => repository.clear()).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('StatsStorageException -> propagates', () async {
    when(() => repository.clear()).thenThrow(const StatsStorageException());
    await expectLater(
      sut(const NoParams()),
      throwsA(const StatsStorageException()),
    );
  });
}
