import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../game/board.dart';
import '../../game/game_provider.dart';
import '../../data/settings_provider.dart';
import '../../data/stats_database.dart';
import '../../theme/app_theme.dart';
import '../widgets/cell_widget.dart';
import '../widgets/game_header.dart';

/// Main game screen with the Minesweeper board.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _gameRecorded = false;

  @override
  Widget build(BuildContext context) {
    return Consumer2<GameProvider, SettingsProvider>(
      builder: (context, game, settings, child) {
        // Record game when finished
        if (game.isGameOver && !_gameRecorded) {
          _recordGame(game);
        }

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                GameHeader(
                  minesRemaining: game.remainingMines,
                  secondsElapsed: game.secondsElapsed,
                  status: game.status,
                  onReset: () => _resetGame(game),
                ),
                Expanded(
                  child: _buildBoard(context, game, settings),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.small(
            onPressed: settings.toggleLockMode,
            backgroundColor: settings.lockMode
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Icon(
              settings.lockMode ? Icons.lock : Icons.lock_open,
              color: settings.lockMode
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBoard(BuildContext context, GameProvider game, SettingsProvider settings) {
    final board = game.board;
    
    // Calculate if we need zoom (expert and larger grids)
    final needsZoom = board.cols > 16 || board.rows > 16;
    final minScale = needsZoom ? 0.5 : 1.0;
    final maxScale = needsZoom ? 3.0 : 2.5;

    return LayoutBuilder(
      builder: (context, outerConstraints) {
        // Use full available space
        final availableHeight = outerConstraints.maxHeight;
        final availableWidth = outerConstraints.maxWidth;
        
        // Calculate cell size to fit within constraints
        final cellSizeByWidth = availableWidth / board.cols;
        final cellSizeByHeight = availableHeight / board.rows;
        final cellSize = cellSizeByWidth < cellSizeByHeight 
            ? cellSizeByWidth 
            : cellSizeByHeight;
        
        final boardWidth = cellSize * board.cols;
        final boardHeight = cellSize * board.rows;

        return Center(
          child: InteractiveViewer(
            minScale: minScale,
            maxScale: maxScale,
            boundaryMargin: const EdgeInsets.all(20),
            child: Container(
              width: boardWidth,
              height: boardHeight,
              decoration: BoxDecoration(
                color: Theme.of(context).minesweeper.cellShadow,
                border: Border.all(
                  color: Theme.of(context).minesweeper.cellShadow,
                  width: 3,
                ),
              ),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: board.cols,
                ),
                itemCount: board.rows * board.cols,
                itemBuilder: (context, index) {
                  final row = index ~/ board.cols;
                  final col = index % board.cols;
                  final cell = board.getCell(row, col);

                  return CellWidget(
                    cell: cell,
                    size: cellSize,
                    isGameOver: game.isGameOver,
                    isLocked: settings.lockMode,
                    holdDelay: settings.holdDelay,
                    onTap: () => game.reveal(row, col),
                    onLongPress: () => game.toggleFlag(row, col),
                    onDoubleTap: () => game.chordReveal(row, col),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _resetGame(GameProvider game) {
    setState(() {
      _gameRecorded = false;
    });
    game.newGame();
  }

  Future<void> _recordGame(GameProvider game) async {
    _gameRecorded = true;

    final record = GameRecord(
      difficulty: game.config.displayName,
      rows: game.config.rows,
      cols: game.config.cols,
      mines: game.config.mines,
      won: game.status == GameStatus.won,
      durationSeconds: game.secondsElapsed,
      timestamp: DateTime.now(),
      seed: game.board.seed,
    );

    await StatsDatabase.instance.insertGame(record);
  }
}
