import 'package:checkers_app/core/l10n/l10n.dart';
import 'package:checkers_app/core/theme/app_colors.dart';
import 'package:checkers_app/core/theme/app_durations.dart';
import 'package:checkers_app/core/theme/app_spacing.dart';
import 'package:checkers_app/features/game/domain/game_domain.dart';
import 'package:checkers_app/features/game/presentation/widgets/board_painter.dart';
import 'package:flutter/material.dart';

/// Square board that reports taps as [Position]s and animates every new
/// [lastMove] along its path.
class BoardView extends StatefulWidget {
  const BoardView({
    required this.board,
    required this.selection,
    required this.lastMove,
    required this.onSquareTap,
    this.flipped = false,
    super.key,
  });

  final Board board;
  final MoveSelection selection;
  final Move? lastMove;
  final ValueChanged<Position> onSquareTap;

  /// Black's side at the bottom.
  final bool flipped;

  /// Time a piece needs to cross one square of its path.
  static const Duration stepDuration = AppDurations.medium;

  @override
  State<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Board? _previousBoard;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, value: 1);
  }

  @override
  void didUpdateWidget(BoardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final move = widget.lastMove;
    final moved =
        move != null &&
        move != oldWidget.lastMove &&
        widget.board != oldWidget.board;
    if (!moved) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      return;
    }
    _previousBoard = oldWidget.board;
    _controller
      ..duration = BoardView.stepDuration * (move.path.length - 1)
      ..forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = widget.flipped ? 'black' : 'white';
    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.boardFrame,
          borderRadius: BorderRadius.circular(AppSpacing.s),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s),
          child: Semantics(
            container: true,
            explicitChildNodes: true,
            label: l10n.boardLabel(l10n.colorName(color)),
            child: LayoutBuilder(
              builder: (context, constraints) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                // Screen readers tap the per-square nodes of the painter;
                // one unlabeled board-sized button would only confuse them.
                excludeFromSemantics: true,
                onTapUp: (details) => widget.onSquareTap(
                  positionAt(
                    details.localPosition,
                    constraints.maxWidth,
                    flipped: widget.flipped,
                  ),
                ),
                // The board repaints on every move and animation tick,
                // independently of the page.
                child: RepaintBoundary(
                  child: CustomPaint(
                    size: Size.square(constraints.maxWidth),
                    painter: BoardPainter(
                      board: widget.board,
                      selection: widget.selection,
                      lastMove: widget.lastMove,
                      previousBoard: _previousBoard,
                      animation: _controller,
                      flipped: widget.flipped,
                      l10n: l10n,
                      textDirection: Directionality.of(context),
                      onSquareTap: widget.onSquareTap,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
