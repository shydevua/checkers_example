// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_stats_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameStatsDto _$GameStatsDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('GameStatsDto', json, ($checkedConvert) {
      final val = GameStatsDto(
        easy: $checkedConvert(
          'easy',
          (v) => LevelStatsDto.fromJson(v as Map<String, dynamic>),
        ),
        medium: $checkedConvert(
          'medium',
          (v) => LevelStatsDto.fromJson(v as Map<String, dynamic>),
        ),
        hard: $checkedConvert(
          'hard',
          (v) => LevelStatsDto.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$GameStatsDtoToJson(GameStatsDto instance) =>
    <String, dynamic>{
      'easy': instance.easy.toJson(),
      'medium': instance.medium.toJson(),
      'hard': instance.hard.toJson(),
    };

LevelStatsDto _$LevelStatsDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LevelStatsDto', json, ($checkedConvert) {
      final val = LevelStatsDto(
        wins: $checkedConvert('wins', (v) => (v as num).toInt()),
        losses: $checkedConvert('losses', (v) => (v as num).toInt()),
        draws: $checkedConvert('draws', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$LevelStatsDtoToJson(LevelStatsDto instance) =>
    <String, dynamic>{
      'wins': instance.wins,
      'losses': instance.losses,
      'draws': instance.draws,
    };
