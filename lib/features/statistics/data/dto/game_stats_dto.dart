import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'game_stats_dto.g.dart';

@JsonSerializable(checked: true, explicitToJson: true)
final class GameStatsDto extends Equatable {
  const GameStatsDto({
    required this.easy,
    required this.medium,
    required this.hard,
  });

  /// Throws [CheckedFromJsonException] if [json] does not match the schema.
  factory GameStatsDto.fromJson(Map<String, dynamic> json) =>
      _$GameStatsDtoFromJson(json);

  final LevelStatsDto easy;
  final LevelStatsDto medium;
  final LevelStatsDto hard;

  Map<String, dynamic> toJson() => _$GameStatsDtoToJson(this);

  @override
  List<Object?> get props => [easy, medium, hard];
}

@JsonSerializable(checked: true)
final class LevelStatsDto extends Equatable {
  const LevelStatsDto({
    required this.wins,
    required this.losses,
    required this.draws,
  });

  /// Throws [CheckedFromJsonException] if [json] does not match the schema.
  factory LevelStatsDto.fromJson(Map<String, dynamic> json) =>
      _$LevelStatsDtoFromJson(json);

  final int wins;
  final int losses;
  final int draws;

  Map<String, dynamic> toJson() => _$LevelStatsDtoToJson(this);

  @override
  List<Object?> get props => [wins, losses, draws];
}
