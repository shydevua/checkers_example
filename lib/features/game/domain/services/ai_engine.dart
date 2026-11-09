import 'dart:math';

import 'package:checkers_app/features/game/domain/entities/board.dart';
import 'package:checkers_app/features/game/domain/entities/game.dart';
import 'package:checkers_app/features/game/domain/entities/move.dart';
import 'package:checkers_app/features/game/domain/entities/piece.dart';
import 'package:checkers_app/features/game/domain/exceptions/game_exception.dart';
import 'package:checkers_app/features/game/domain/services/board_evaluator.dart';
import 'package:checkers_app/features/game/domain/services/checkers_rules.dart';
import 'package:checkers_app/features/game/domain/services/difficulty_settings.dart';
import 'package:checkers_app/features/game/domain/services/zobrist.dart';
import 'package:checkers_app/features/shared/game_results/difficulty.dart';

/// Computer opponent: negamax with alpha-beta pruning, a transposition table
/// and iterative deepening under a time budget.
///
/// Pending captures are always searched to the end (every capture removes a
/// piece, so this terminates), so even shallow levels do not walk into an
/// obvious multi-capture.
class AiEngine {
  const AiEngine({
    CheckersRules rules = const CheckersRules(),
    BoardEvaluator evaluator = const BoardEvaluator(),
  }) : _rules = rules,
       _evaluator = evaluator;

  /// Score of a won position; faster wins score higher. Every reachable
  /// score lies in `[-winScore, winScore]`.
  static const winScore = 1000000;

  final CheckersRules _rules;
  final BoardEvaluator _evaluator;

  /// The move the computer plays in [game] at [difficulty].
  ///
  /// Throws [GameAlreadyOverException] if [game] is finished.
  Move bestMove(Game game, Difficulty difficulty, Random random) =>
      bestMoveWith(game, difficulty.settings, random);

  /// The move the computer plays in [game] with [settings].
  ///
  /// [random] decides random moves and breaks ties between equal moves.
  ///
  /// Throws [GameAlreadyOverException] if [game] is finished.
  Move bestMoveWith(Game game, SearchSettings settings, Random random) {
    if (game.isOver) throw const GameAlreadyOverException();
    final moves = game.legalMoves;
    if (moves.length == 1) return moves.single;
    if (random.nextDouble() < settings.randomMoveChance) {
      return moves[random.nextInt(moves.length)];
    }
    final best = _Search(
      this,
      settings.timeLimit,
    ).deepen(game.board, game.turn, moves, settings.maxDepth);
    return best[random.nextInt(best.length)];
  }

  /// All [moves] of [color] sharing the best score after a search of
  /// [depth] half-moves, in their original order. No time limit.
  List<Move> bestMoves(
    Board board,
    PieceColor color,
    List<Move> moves,
    int depth,
  ) => _Search(this, null).root(board, color, moves, depth);

  /// Exact score of playing [move] for [color], searching [depth]
  /// half-moves including [move] itself.
  int moveScore(Board board, PieceColor color, Move move, int depth) =>
      _Search(this, null).moveScore(board, color, move, depth);

  /// Exact negamax score of [board] for [color] to move.
  int score(Board board, PieceColor color, int depth) => _Search(
    this,
    null,
  ).negamax(board, color, depth, -winScore, winScore, 0);
}

enum _Bound { exact, lower, upper }

final class _Entry {
  const _Entry(this.depth, this.score, this.bound, this.best);

  final int depth;
  final int score;
  final _Bound bound;

  /// Index of the best move in the position's legal moves.
  final int best;
}

/// State of one search: its transposition table and clock. Lives only for
/// one call, inside the search isolate.
final class _Search {
  _Search(this._engine, this._timeLimit);

  final AiEngine _engine;
  final Duration? _timeLimit;
  final Stopwatch _clock = Stopwatch()..start();
  final Map<int, _Entry> _table = {};
  var _nodes = 0;
  var _aborted = false;

  static const int _maxTableSize = 1 << 20;
  static const _clockCheckInterval = 1024;

  /// Deepens one half-move at a time until [maxDepth] or the time limit;
  /// returns the best moves of the last completed depth.
  List<Move> deepen(
    Board board,
    PieceColor color,
    List<Move> moves,
    int maxDepth,
  ) {
    // Fallback if even depth 1 runs out of time: any legal move.
    var best = moves;
    for (var depth = 1; depth <= maxDepth; depth++) {
      final result = root(board, color, moves, depth);
      if (_aborted) break;
      best = result;
    }
    return best;
  }

  List<Move> root(Board board, PieceColor color, List<Move> moves, int depth) {
    int? bestScore;
    var best = <Move>[];
    for (final move in moves) {
      final score = moveScore(board, color, move, depth);
      if (_aborted) return best;
      if (bestScore == null || score > bestScore) {
        bestScore = score;
        best = [move];
      } else if (score == bestScore) {
        best.add(move);
      }
    }
    return best;
  }

  /// Full window: root scores are exact, so ties are detected reliably.
  int moveScore(Board board, PieceColor color, Move move, int depth) =>
      -negamax(
        _engine._rules.apply(board, move),
        color.opponent,
        depth - 1,
        -AiEngine.winScore,
        AiEngine.winScore,
        1,
      );

  /// Fail-hard alpha-beta: the result is clamped to `[alpha, beta]`.
  int negamax(
    Board board,
    PieceColor color,
    int depth,
    int alpha,
    int beta,
    int ply,
  ) {
    if (_timedOut()) return 0;
    final moves = _engine._rules.legalMoves(board, color);
    if (moves.isEmpty) return ply - AiEngine.winScore;
    if (depth <= 0 && !moves[0].isCapture) {
      return _engine._evaluator.evaluate(board, color);
    }
    final key = Zobrist.hash(board, color);
    final entry = _table[key];
    if (entry != null && entry.depth >= depth) {
      final stored = _fromTable(entry.score, ply);
      switch (entry.bound) {
        case _Bound.exact:
          return stored;
        case _Bound.lower when stored >= beta:
          return beta;
        case _Bound.upper when stored <= alpha:
          return alpha;
        case _Bound.lower || _Bound.upper:
          break;
      }
    }
    // The best move of an earlier search goes first: earlier cut-offs.
    final first = entry?.best ?? 0;
    var low = alpha;
    var best = first;
    for (var i = 0; i < moves.length; i++) {
      final index = i == 0 ? first : (i <= first ? i - 1 : i);
      final value = -negamax(
        _engine._rules.apply(board, moves[index]),
        color.opponent,
        depth - 1,
        -beta,
        -low,
        ply + 1,
      );
      if (_aborted) return 0;
      if (value >= beta) {
        _store(key, depth, beta, _Bound.lower, index, ply);
        return beta;
      }
      if (value > low) {
        low = value;
        best = index;
      }
    }
    _store(
      key,
      depth,
      low,
      low > alpha ? _Bound.exact : _Bound.upper,
      best,
      ply,
    );
    return low;
  }

  bool _timedOut() {
    final limit = _timeLimit;
    if (_aborted || limit == null) return _aborted;
    _nodes++;
    if (_nodes % _clockCheckInterval == 0 && _clock.elapsed >= limit) {
      _aborted = true;
    }
    return _aborted;
  }

  void _store(int key, int depth, int score, _Bound bound, int best, int ply) {
    if (_table.length >= _maxTableSize) _table.clear();
    _table[key] = _Entry(depth, _toTable(score, ply), bound, best);
  }

  // Win scores depend on the distance from the root; the table keeps them
  // relative to the stored position so they can be reused at another ply.
  static const int _winThreshold = AiEngine.winScore ~/ 2;

  static int _toTable(int score, int ply) => score > _winThreshold
      ? score + ply
      : (score < -_winThreshold ? score - ply : score);

  static int _fromTable(int score, int ply) => score > _winThreshold
      ? score - ply
      : (score < -_winThreshold ? score + ply : score);
}
