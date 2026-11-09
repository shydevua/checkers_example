import 'dart:math' as math;

import 'package:checkers_app/core/l10n/l10n.dart';
import 'package:checkers_app/core/theme/app_colors.dart';
import 'package:checkers_app/features/game/domain/game_domain.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

/// Paints the whole board in one pass (squares, highlights, pieces) and
/// describes every dark square to screen readers.
///
/// While [animation] runs, the piece of [lastMove] travels along its path
/// and the pieces it captures fade out; [previousBoard] is the position
/// before the move. Only the painter repaints on animation ticks.
class BoardPainter extends CustomPainter {
  BoardPainter({
    required this.board,
    required this.selection,
    required this.lastMove,
    required this.l10n,
    required this.textDirection,
    required this.onSquareTap,
    this.previousBoard,
    this.animation = kAlwaysCompleteAnimation,
    this.flipped = false,
  }) : super(repaint: animation);

  final Board board;
  final MoveSelection selection;
  final Move? lastMove;
  final Board? previousBoard;
  final Animation<double> animation;

  /// Black's side at the bottom (the human plays black).
  final bool flipped;

  final AppLocalizations l10n;

  /// Required by screen readers for every labelled node.
  final TextDirection textDirection;
  final ValueChanged<Position> onSquareTap;

  static final _light = Paint()..color = AppColors.boardLight;
  static final _dark = Paint()..color = AppColors.boardDark;
  static final _lastMove = Paint()..color = AppColors.lastMove;
  static final _movable = Paint()..color = AppColors.movable;
  static final _target = Paint()..color = AppColors.target;
  static final _selected = Paint()
    ..color = AppColors.selected
    ..style = PaintingStyle.stroke;
  static final _crown = Paint()..color = AppColors.crown;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / Position.size;
    final progress = animation.value;
    final animating = progress < 1 && previousBoard != null && lastMove != null;
    final last = {...?lastMove?.path};
    for (final position in Position.all) {
      final rect = squareRect(position, cell, flipped: flipped);
      canvas.drawRect(rect, position.isDark ? _dark : _light);
      if (last.contains(position)) canvas.drawRect(rect, _lastMove);
      if (selection.path.isEmpty && selection.movable.contains(position)) {
        canvas.drawRect(rect, _movable);
      }
      if (selection.path.contains(position)) {
        _selected.strokeWidth = cell * 0.08;
        canvas.drawRect(rect.deflate(cell * 0.04), _selected);
      }
      final piece = board.pieceAt(position);
      final hidden =
          _isVacated(position) || (animating && position == lastMove!.to);
      if (piece != null && !hidden) {
        _paintPiece(canvas, rect.center, cell, piece);
      }
      if (selection.targets.contains(position)) {
        canvas.drawCircle(rect.center, cell * 0.16, _target);
      }
    }
    if (animating) _paintMove(canvas, cell, progress);
    final current = selection.current;
    if (current != null && selection.path.length > 1) {
      final piece = board.pieceAt(selection.path.first)!;
      _paintPiece(
        canvas,
        squareRect(current, cell, flipped: flipped).center,
        cell,
        piece,
      );
    }
  }

  /// Captured pieces fade while the mover travels the path segment by
  /// segment.
  void _paintMove(Canvas canvas, double cell, double progress) {
    final move = lastMove!;
    final before = previousBoard!;
    final segments = move.path.length - 1;
    final travelled = progress * segments;
    final segment = math.min(travelled.floor(), segments - 1);
    for (var i = 0; i < move.captured.length; i++) {
      final piece = before.pieceAt(move.captured[i]);
      final opacity = (1 - (travelled - i)).clamp(0.0, 1.0);
      if (piece == null || opacity == 0) continue;
      _paintPiece(
        canvas,
        squareRect(move.captured[i], cell, flipped: flipped).center,
        cell,
        piece,
        opacity: opacity,
      );
    }
    final from = squareRect(move.path[segment], cell, flipped: flipped);
    final to = squareRect(move.path[segment + 1], cell, flipped: flipped);
    final center = Offset.lerp(from.center, to.center, travelled - segment)!;
    final mover = before.pieceAt(move.from) ?? board.pieceAt(move.to)!;
    _paintPiece(canvas, center, cell, mover);
  }

  /// The selected piece is drawn where the partial capture path ends.
  bool _isVacated(Position position) =>
      selection.path.length > 1 && selection.path.first == position;

  void _paintPiece(
    Canvas canvas,
    Offset center,
    double cell,
    Piece piece, {
    double opacity = 1,
  }) {
    final radius = cell * 0.38;
    final white = piece.color == PieceColor.white;
    final fill = white ? AppColors.pieceWhite : AppColors.pieceBlack;
    final edgeColor = white
        ? AppColors.pieceWhiteEdge
        : AppColors.pieceBlackEdge;
    final body = Paint()..color = fill.withValues(alpha: opacity);
    final edge = Paint()
      ..color = edgeColor.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = cell * 0.05;
    canvas
      ..drawCircle(center, radius, body)
      ..drawCircle(center, radius, edge)
      ..drawCircle(center, radius * 0.62, edge);
    if (piece.isKing) _paintCrown(canvas, center, radius * 0.5);
  }

  void _paintCrown(Canvas canvas, Offset center, double r) {
    final path = Path()
      ..moveTo(center.dx - r, center.dy + r * 0.6)
      ..lineTo(center.dx - r, center.dy - r * 0.4)
      ..lineTo(center.dx - r * 0.5, center.dy)
      ..lineTo(center.dx, center.dy - r * 0.8)
      ..lineTo(center.dx + r * 0.5, center.dy)
      ..lineTo(center.dx + r, center.dy - r * 0.4)
      ..lineTo(center.dx + r, center.dy + r * 0.6)
      ..close();
    canvas.drawPath(path, _crown);
  }

  @override
  SemanticsBuilderCallback get semanticsBuilder => (size) {
    final cell = size.width / Position.size;
    return [
      for (final position in Position.all)
        if (position.isDark)
          CustomPainterSemantics(
            key: ValueKey(position.notation),
            rect: squareRect(position, cell, flipped: flipped),
            properties: _squareSemantics(position),
          ),
    ];
  };

  SemanticsProperties _squareSemantics(Position position) {
    final canMove =
        selection.path.isEmpty && selection.movable.contains(position);
    final selected =
        selection.path.isNotEmpty && selection.path.first == position;
    final target = selection.targets.contains(position);
    final content = [
      l10n.piece(pieceKind(board.pieceAt(position))),
      if (selected) l10n.squareSelected,
      if (canMove) l10n.squareCanMove,
      if (target) l10n.squareTarget,
      if (lastMove?.path.contains(position) ?? false) l10n.squareLastMove,
    ].join(', ');
    final actionable =
        canMove || selected || target || selection.movable.contains(position);
    return SemanticsProperties(
      label: l10n.squareLabel(position.notation, content),
      hint: target
          ? l10n.moveHereHint
          : (actionable ? l10n.selectPieceHint : null),
      textDirection: textDirection,
      selected: selected,
      button: actionable,
      onTap: actionable ? () => onSquareTap(position) : null,
    );
  }

  @override
  bool shouldRepaint(BoardPainter oldDelegate) =>
      board != oldDelegate.board ||
      selection != oldDelegate.selection ||
      lastMove != oldDelegate.lastMove ||
      previousBoard != oldDelegate.previousBoard ||
      animation != oldDelegate.animation ||
      flipped != oldDelegate.flipped;

  @override
  bool shouldRebuildSemantics(BoardPainter oldDelegate) =>
      board != oldDelegate.board ||
      selection != oldDelegate.selection ||
      lastMove != oldDelegate.lastMove ||
      flipped != oldDelegate.flipped ||
      l10n != oldDelegate.l10n ||
      textDirection != oldDelegate.textDirection;
}

/// Key of a piece for the `piece` l10n select (`none` for an empty square).
String pieceKind(Piece? piece) => switch (piece) {
  null => 'none',
  Piece(color: PieceColor.white, isKing: false) => 'whiteMan',
  Piece(color: PieceColor.black, isKing: false) => 'blackMan',
  Piece(color: PieceColor.white, isKing: true) => 'whiteKing',
  Piece(color: PieceColor.black, isKing: true) => 'blackKing',
};

/// Where [position] is drawn on a board of [cell]-sized squares.
Rect squareRect(Position position, double cell, {bool flipped = false}) {
  final row = flipped ? Position.size - 1 - position.row : position.row;
  final col = flipped ? Position.size - 1 - position.col : position.col;
  return Rect.fromLTWH(col * cell, row * cell, cell, cell);
}

/// Converts a tap at [offset] on a board of [side] logical pixels to a
/// square. Taps on the very edge belong to the nearest square.
Position positionAt(Offset offset, double side, {bool flipped = false}) {
  final cell = side / Position.size;
  int index(double value) =>
      math.min(math.max((value / cell).floor(), 0), Position.size - 1);
  final row = index(offset.dy);
  final col = index(offset.dx);
  return flipped
      ? Position(Position.size - 1 - row, Position.size - 1 - col)
      : Position(row, col);
}
