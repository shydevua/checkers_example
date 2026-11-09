import 'package:checkers_app/features/game/domain/entities/board.dart';
import 'package:checkers_app/features/game/domain/entities/game.dart';
import 'package:checkers_app/features/game/domain/entities/move.dart';
import 'package:checkers_app/features/game/domain/entities/piece.dart';
import 'package:checkers_app/features/game/domain/exceptions/game_exception.dart';
import 'package:checkers_app/features/game/domain/services/zobrist.dart';
import 'package:checkers_app/features/game/domain/value_objects/position.dart';

/// Rules of Russian checkers:
///
/// * men move one square diagonally forward and capture in all four
///   directions;
/// * kings fly: they move and capture along a whole diagonal;
/// * capturing is mandatory, but any capturing sequence may be chosen;
/// * a capturing piece must continue while it can; a king that has a choice
///   of landing squares must pick one from which it can continue;
/// * captured pieces are removed after the move ("Turkish strike" rule):
///   they cannot be jumped twice and they block the way;
/// * a man reaching the last row is crowned and, if it is in the middle of
///   a capture, continues capturing as a king;
/// * a side without legal moves loses;
/// * the game is drawn after [drawAfterQuietKingMoves] half-moves made only
///   by kings without any capture, when the same position occurs
///   [drawAfterRepetitions] times with the same side to move, or when three
///   or more kings fail to beat a lone king in [drawAfterKingEndgameMoves]
///   half-moves.
class CheckersRules {
  const CheckersRules();

  /// 15 moves of each side.
  static const drawAfterQuietKingMoves = 30;

  /// Threefold repetition.
  static const drawAfterRepetitions = 3;

  /// 15 moves of each side.
  static const drawAfterKingEndgameMoves = 30;

  static const _directions = [(-1, -1), (-1, 1), (1, -1), (1, 1)];

  /// The starting position with white to move.
  Game newGame() => gameFrom(Board.initial(), turn: PieceColor.white);

  /// A game at [board] with [turn] to move; [legalMoves] and the status are
  /// derived from the position.
  Game gameFrom(
    Board board, {
    required PieceColor turn,
    int quietKingMoves = 0,
    int kingEndgameMoves = 0,
    Map<int, int> repetitions = const {},
    Move? lastMove,
  }) {
    final moves = legalMoves(board, turn);
    final key = Zobrist.hash(board, turn);
    final seen = Map<int, int>.unmodifiable({
      ...repetitions,
      key: (repetitions[key] ?? 0) + 1,
    });
    final GameStatus status;
    if (moves.isEmpty) {
      status = turn == PieceColor.white
          ? GameStatus.blackWon
          : GameStatus.whiteWon;
    } else if (quietKingMoves >= drawAfterQuietKingMoves ||
        seen[key]! >= drawAfterRepetitions ||
        kingEndgameMoves >= drawAfterKingEndgameMoves) {
      status = GameStatus.draw;
    } else {
      status = GameStatus.ongoing;
    }
    return Game(
      board: board,
      turn: turn,
      legalMoves: status == GameStatus.ongoing ? moves : const [],
      status: status,
      quietKingMoves: quietKingMoves,
      kingEndgameMoves: kingEndgameMoves,
      repetitions: seen,
      lastMove: lastMove,
    );
  }

  /// Whether one side has three or more kings and no men against a single
  /// king (and nothing else).
  bool isKingEndgame(Board board) {
    bool lone(PieceColor color) {
      final pieces = board.positionsOf(color).toList();
      return pieces.length == 1 && board.pieceAt(pieces.single)!.isKing;
    }

    bool strong(PieceColor color) {
      final pieces = board.positionsOf(color).toList();
      return pieces.length >= 3 &&
          pieces.every((position) => board.pieceAt(position)!.isKing);
    }

    return (strong(PieceColor.white) && lone(PieceColor.black)) ||
        (strong(PieceColor.black) && lone(PieceColor.white));
  }

  /// Plays [move] in [game] and returns the next position.
  ///
  /// Throws [GameAlreadyOverException] if [game] is finished or
  /// [IllegalMoveException] if [move] is not one of [Game.legalMoves].
  Game play(Game game, Move move) {
    if (game.isOver) throw const GameAlreadyOverException();
    if (!game.legalMoves.contains(move)) throw const IllegalMoveException();
    final mover = game.board.pieceAt(move.from)!;
    final irreversible = move.isCapture || !mover.isKing;
    final board = apply(game.board, move);
    return gameFrom(
      board,
      turn: game.turn.opponent,
      quietKingMoves: irreversible ? 0 : game.quietKingMoves + 1,
      kingEndgameMoves: isKingEndgame(board) ? game.kingEndgameMoves + 1 : 0,
      // Positions before a capture or a man move cannot come back.
      repetitions: irreversible ? const {} : game.repetitions,
      lastMove: move,
    );
  }

  /// [board] after [move], without checking legality. Used by the search.
  Board apply(Board board, Move move) {
    final mover = board.pieceAt(move.from)!;
    final crowned =
        mover.isKing || move.path.any((p) => p.row == mover.color.promotionRow);
    return board.updated({
      move.from: null,
      for (final captured in move.captured) captured: null,
      move.to: crowned ? mover.crowned() : mover,
    });
  }

  /// Every legal move of [color]: all captures if there is at least one,
  /// otherwise all quiet moves.
  List<Move> legalMoves(Board board, PieceColor color) {
    final captures = <Move>[];
    for (final from in board.positionsOf(color)) {
      final piece = board.pieceAt(from)!;
      captures.addAll(
        _captureSequences(board, from, color, [from], const {}, piece.isKing),
      );
    }
    if (captures.isNotEmpty) return captures;
    return [
      for (final from in board.positionsOf(color))
        ..._quietMoves(board, from, board.pieceAt(from)!),
    ];
  }

  Iterable<Move> _quietMoves(Board board, Position from, Piece piece) sync* {
    for (final (dRow, dCol) in _directions) {
      if (!piece.isKing && dRow != piece.color.forward) continue;
      var to = from.offset(dRow, dCol);
      while (to != null && board.isEmptyAt(to)) {
        yield Move([from, to]);
        if (!piece.isKing) break;
        to = to.offset(dRow, dCol);
      }
    }
  }

  List<Move> _captureSequences(
    Board board,
    Position origin,
    PieceColor color,
    List<Position> path,
    Set<int> captured,
    bool isKing,
  ) {
    final jumps = _jumps(board, origin, color, path.last, captured, isKing);
    if (jumps.isEmpty) {
      return path.length > 1
          ? [Move(path, captured: _capturedPositions(captured))]
          : const [];
    }
    final moves = <Move>[];
    for (final group in _groupByCaptured(jumps)) {
      final continuing = group.where(
        (jump) => _jumps(
          board,
          origin,
          color,
          jump.landing,
          {...captured, jump.captured.index},
          isKing || jump.crowns,
        ).isNotEmpty,
      );
      for (final jump in continuing.isEmpty ? group : continuing) {
        moves.addAll(
          _captureSequences(
            board,
            origin,
            color,
            [...path, jump.landing],
            {...captured, jump.captured.index},
            isKing || jump.crowns,
          ),
        );
      }
    }
    return moves;
  }

  /// Single jumps available from [at]. [origin] counts as empty because the
  /// moving piece has left it; [captured] pieces stay on the board.
  List<_Jump> _jumps(
    Board board,
    Position origin,
    PieceColor color,
    Position at,
    Set<int> captured,
    bool isKing,
  ) {
    bool isEmpty(Position p) => p == origin || board.isEmptyAt(p);

    final jumps = <_Jump>[];
    for (final (dRow, dCol) in _directions) {
      var over = at.offset(dRow, dCol);
      while (isKing && over != null && isEmpty(over)) {
        over = over.offset(dRow, dCol);
      }
      if (over == null || captured.contains(over.index)) continue;
      if (board.pieceAt(over)?.color != color.opponent) continue;
      var landing = over.offset(dRow, dCol);
      while (landing != null && isEmpty(landing)) {
        final crowns = !isKing && landing.row == color.promotionRow;
        jumps.add(_Jump(captured: over, landing: landing, crowns: crowns));
        if (!isKing) break;
        landing = landing.offset(dRow, dCol);
      }
    }
    return jumps;
  }

  static Iterable<List<_Jump>> _groupByCaptured(List<_Jump> jumps) {
    final groups = <Position, List<_Jump>>{};
    for (final jump in jumps) {
      (groups[jump.captured] ??= []).add(jump);
    }
    return groups.values;
  }

  static List<Position> _capturedPositions(Set<int> captured) => [
    for (final index in captured) Position.all[index],
  ];
}

final class _Jump {
  const _Jump({
    required this.captured,
    required this.landing,
    required this.crowns,
  });

  final Position captured;
  final Position landing;
  final bool crowns;
}
