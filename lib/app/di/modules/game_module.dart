import 'dart:math';

import 'package:checkers_app/core/analytics/track_event.dart';
import 'package:checkers_app/features/game/domain/game_domain.dart';
import 'package:checkers_app/features/game/presentation/bloc/game/ai_move_delay.dart';
import 'package:checkers_app/features/game/presentation/bloc/game/game_bloc.dart';
import 'package:checkers_app/features/shared/game_results/game_result_recorder.dart';
import 'package:injectable/injectable.dart';

/// Game feature: domain services, use cases and the bloc.
@module
abstract class GameModule {
  @lazySingleton
  CheckersRules get rules => const CheckersRules();

  @lazySingleton
  AiEngine get aiEngine => const AiEngine();

  @lazySingleton
  AiMoveDelay get aiMoveDelay => const AiMoveDelay(Duration(milliseconds: 450));

  @lazySingleton
  StartNewGame startNewGame(CheckersRules rules) => StartNewGame(rules);

  @lazySingleton
  SelectSquare get selectSquare => const SelectSquare();

  @lazySingleton
  MakeMove makeMove(CheckersRules rules) => MakeMove(rules);

  /// Seeds for the search come from a private generator, not a shared
  /// `Random` registered for everyone.
  @lazySingleton
  ComputeAiMove computeAiMove(AiEngine engine) =>
      ComputeAiMove(engine, Random());

  /// [GameResultRecorder] is bound by whichever feature keeps results.
  @lazySingleton
  SaveGameResult saveGameResult(GameResultRecorder recorder) =>
      SaveGameResult(recorder);

  /// Blocs are factories: a new one for every game screen.
  @injectable
  GameBloc gameBloc(
    StartNewGame startNewGame,
    SelectSquare selectSquare,
    MakeMove makeMove,
    ComputeAiMove computeAiMove,
    SaveGameResult saveGameResult,
    TrackEvent trackEvent,
    AiMoveDelay aiMoveDelay,
  ) => GameBloc(
    startNewGame,
    selectSquare,
    makeMove,
    computeAiMove,
    saveGameResult,
    trackEvent,
    aiMoveDelay,
  );
}
