/// Predefined difficulty levels.
enum Difficulty { beginner, intermediate, expert, custom }

/// Configuration for a game board.
class GameConfig {
  final Difficulty difficulty;
  final int rows;
  final int cols;
  final int mines;

  const GameConfig({
    required this.difficulty,
    required this.rows,
    required this.cols,
    required this.mines,
  });

  /// Beginner: 9x9, 10 mines
  static const beginner = GameConfig(
    difficulty: Difficulty.beginner,
    rows: 9,
    cols: 9,
    mines: 10,
  );

  /// Intermediate: 16x16, 40 mines
  static const intermediate = GameConfig(
    difficulty: Difficulty.intermediate,
    rows: 16,
    cols: 16,
    mines: 40,
  );

  /// Expert: 30x16, 99 mines (tall grid for mobile)
  static const expert = GameConfig(
    difficulty: Difficulty.expert,
    rows: 30,
    cols: 16,
    mines: 99,
  );

  /// Create a custom configuration.
  factory GameConfig.custom({
    required int rows,
    required int cols,
    required int mines,
  }) {
    // Clamp values to reasonable ranges
    final clampedRows = rows.clamp(5, 30);
    final clampedCols = cols.clamp(5, 50);
    final maxMines = (clampedRows * clampedCols * 0.9).floor();
    final clampedMines = mines.clamp(1, maxMines);

    return GameConfig(
      difficulty: Difficulty.custom,
      rows: clampedRows,
      cols: clampedCols,
      mines: clampedMines,
    );
  }

  String get displayName {
    switch (difficulty) {
      case Difficulty.beginner:
        return 'Beginner';
      case Difficulty.intermediate:
        return 'Intermediate';
      case Difficulty.expert:
        return 'Expert';
      case Difficulty.custom:
        return 'Custom';
    }
  }

  @override
  String toString() => '$displayName (${rows}x$cols, $mines mines)';
}
