import 'package:checkers_app/features/statistics/data/dto/game_stats_dto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_annotation/json_annotation.dart';

void main() {
  const dto = GameStatsDto(
    easy: LevelStatsDto(wins: 1, losses: 2, draws: 3),
    medium: LevelStatsDto(wins: 4, losses: 5, draws: 6),
    hard: LevelStatsDto(wins: 7, losses: 8, draws: 9),
  );
  final json = <String, dynamic>{
    'easy': {'wins': 1, 'losses': 2, 'draws': 3},
    'medium': {'wins': 4, 'losses': 5, 'draws': 6},
    'hard': {'wins': 7, 'losses': 8, 'draws': 9},
  };

  test('toJson -> nested plain maps', () {
    expect(dto.toJson(), json);
  });

  test('fromJson -> dto', () {
    expect(GameStatsDto.fromJson(json), dto);
  });

  test('fromJson with a wrong type -> CheckedFromJsonException', () {
    expect(
      () => LevelStatsDto.fromJson(const {
        'wins': 'many',
        'losses': 0,
        'draws': 0,
      }),
      throwsA(isA<CheckedFromJsonException>()),
    );
  });

  test('fromJson with a missing key -> CheckedFromJsonException', () {
    expect(
      () => GameStatsDto.fromJson({'easy': json['easy']}),
      throwsA(isA<CheckedFromJsonException>()),
    );
  });
}
