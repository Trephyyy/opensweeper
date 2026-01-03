import 'dart:async';
import 'package:flutter/material.dart';
import '../../game/cell.dart';
import '../../theme/app_theme.dart';

/// Widget representing a single Minesweeper cell with OG 3D beveled look.
/// Uses configurable long-press delay for quick flag toggling.
class CellWidget extends StatefulWidget {
  final Cell cell;
  final double size;
  final bool isGameOver;
  final bool isLocked; // When locked, no interaction (drag mode)
  final Duration holdDelay;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onDoubleTap;

  const CellWidget({
    super.key,
    required this.cell,
    required this.size,
    required this.isGameOver,
    this.isLocked = false,
    this.holdDelay = const Duration(milliseconds: 150),
    required this.onTap,
    required this.onLongPress,
    required this.onDoubleTap,
  });

  @override
  State<CellWidget> createState() => _CellWidgetState();
}

class _CellWidgetState extends State<CellWidget> {
  Timer? _longPressTimer;
  bool _isPressed = false;
  bool _longPressFired = false;

  void _onPointerDown(PointerDownEvent event) {
    if (widget.isLocked) return;
    _isPressed = true;
    _longPressFired = false;
    _longPressTimer = Timer(widget.holdDelay, () {
      if (_isPressed && !_longPressFired) {
        _longPressFired = true;
        widget.onLongPress();
      }
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    _longPressTimer?.cancel();
    if (_isPressed && !_longPressFired && !widget.isLocked) {
      widget.onTap();
    }
    _isPressed = false;
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _longPressTimer?.cancel();
    _isPressed = false;
  }

  @override
  void dispose() {
    _longPressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).minesweeper;

    if (widget.cell.isRevealed) {
      return _buildRevealedCell(context, theme);
    } else {
      return _buildHiddenCell(context, theme);
    }
  }

  Widget _buildHiddenCell(BuildContext context, MinesweeperTheme theme) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: GestureDetector(
        onDoubleTap: widget.isLocked ? null : widget.onDoubleTap,
        child: Container(
          decoration: BoxDecoration(
            color: theme.cellHidden,
            border: Border(
              top: BorderSide(color: theme.cellHighlight, width: 2),
              left: BorderSide(color: theme.cellHighlight, width: 2),
              right: BorderSide(color: theme.cellShadow, width: 2),
              bottom: BorderSide(color: theme.cellShadow, width: 2),
            ),
          ),
          child: widget.cell.isFlagged
              ? Center(
                  child: Icon(
                    Icons.flag,
                    color: theme.flag,
                    size: widget.size * 0.6,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildRevealedCell(BuildContext context, MinesweeperTheme theme) {
    return GestureDetector(
      onDoubleTap: widget.onDoubleTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cellRevealed,
          border: Border.all(
            color: theme.cellShadow.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
        child: Center(child: _buildCellContent(context, theme)),
      ),
    );
  }

  Widget? _buildCellContent(BuildContext context, MinesweeperTheme theme) {
    if (widget.cell.isMine) {
      return Icon(
        Icons.brightness_7,
        color: theme.mine,
        size: widget.size * 0.6,
      );
    }

    if (widget.cell.adjacentMines > 0) {
      return Text(
        '${widget.cell.adjacentMines}',
        style: TextStyle(
          color: AppTheme.numberColors[widget.cell.adjacentMines],
          fontSize: widget.size * 0.6,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      );
    }

    return null;
  }
}
