/// Game domain: rules of Russian checkers, the computer opponent and the use
/// cases of a game. Pure Dart.
library;

export 'package:checkers_app/features/game/domain/entities/board.dart';
export 'package:checkers_app/features/game/domain/entities/game.dart';
export 'package:checkers_app/features/game/domain/entities/move.dart';
export 'package:checkers_app/features/game/domain/entities/piece.dart';
export 'package:checkers_app/features/game/domain/exceptions/game_exception.dart';
export 'package:checkers_app/features/game/domain/services/ai_engine.dart';
export 'package:checkers_app/features/game/domain/services/board_evaluator.dart';
export 'package:checkers_app/features/game/domain/services/checkers_rules.dart';
export 'package:checkers_app/features/game/domain/services/difficulty_settings.dart';
export 'package:checkers_app/features/game/domain/services/zobrist.dart';
export 'package:checkers_app/features/game/domain/usecases/compute_ai_move.dart';
export 'package:checkers_app/features/game/domain/usecases/make_move.dart';
export 'package:checkers_app/features/game/domain/usecases/save_game_result.dart';
export 'package:checkers_app/features/game/domain/usecases/select_square.dart';
export 'package:checkers_app/features/game/domain/usecases/start_new_game.dart';
export 'package:checkers_app/features/game/domain/value_objects/move_selection.dart';
export 'package:checkers_app/features/game/domain/value_objects/position.dart';
