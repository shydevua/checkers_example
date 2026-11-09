import 'package:checkers_app/core/analytics/analytics_event.dart';
import 'package:checkers_app/features/game/domain/game_domain.dart';
import 'package:checkers_app/features/shared/game_results/difficulty.dart';
import 'package:checkers_app/features/shared/game_results/game_outcome.dart';

/// Product events of the game feature.
abstract final class GameAnalytics {
  static AnalyticsEvent started(Difficulty difficulty, PieceColor color) =>
      AnalyticsEvent('game_started', {
        'difficulty': difficulty.name,
        'color': color.name,
      });

  static AnalyticsEvent finished(Difficulty difficulty, GameOutcome outcome) =>
      AnalyticsEvent('game_finished', {
        'difficulty': difficulty.name,
        'outcome': outcome.name,
      });

  static AnalyticsEvent undone(Difficulty difficulty) =>
      AnalyticsEvent('move_undone', {'difficulty': difficulty.name});
}
