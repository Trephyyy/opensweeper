import 'package:flutter/material.dart';
import '../../game/board.dart';
import '../../theme/app_theme.dart';

/// Header widget with mine counter, timer, and reset button (OG style).
class GameHeader extends StatelessWidget {
  final int minesRemaining;
  final int secondsElapsed;
  final GameStatus status;
  final VoidCallback onReset;

  const GameHeader({
    super.key,
    required this.minesRemaining,
    required this.secondsElapsed,
    required this.status,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).minesweeper;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cellHidden,
        border: Border(
          top: BorderSide(color: theme.cellHighlight, width: 2),
          left: BorderSide(color: theme.cellHighlight, width: 2),
          right: BorderSide(color: theme.cellShadow, width: 2),
          bottom: BorderSide(color: theme.cellShadow, width: 2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCounter(context, minesRemaining),
          _buildFaceButton(context),
          _buildCounter(context, secondsElapsed.clamp(0, 999)),
        ],
      ),
    );
  }

  Widget _buildCounter(BuildContext context, int value) {
    final displayValue = value.clamp(-99, 999);
    final text = displayValue.toString().padLeft(3, '0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.grey.shade700, width: 1),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildFaceButton(BuildContext context) {
    final theme = Theme.of(context).minesweeper;

    String emoji;
    switch (status) {
      case GameStatus.ready:
      case GameStatus.playing:
        emoji = '🙂';
        break;
      case GameStatus.won:
        emoji = '😎';
        break;
      case GameStatus.lost:
        emoji = '😵';
        break;
    }

    return GestureDetector(
      onTap: onReset,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: theme.cellHidden,
          border: Border(
            top: BorderSide(color: theme.cellHighlight, width: 2),
            left: BorderSide(color: theme.cellHighlight, width: 2),
            right: BorderSide(color: theme.cellShadow, width: 2),
            bottom: BorderSide(color: theme.cellShadow, width: 2),
          ),
        ),
        child: Center(
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 28),
          ),
        ),
      ),
    );
  }
}
