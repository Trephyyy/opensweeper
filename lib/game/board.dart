import 'dart:math';
import 'cell.dart';
import 'difficulty.dart';

/// Game status.
enum GameStatus {
  ready, // Not started yet
  playing, // Game in progress
  won, // All non-mine cells revealed
  lost, // Mine revealed
}

/// The Minesweeper game board with all game logic.
class Board {
  final GameConfig config;
  final int seed;
  late List<List<Cell>> _grid;
  GameStatus _status = GameStatus.ready;
  int _flagCount = 0;
  int _revealedCount = 0;
  bool _minesPlaced = false;
  DateTime? _startTime;
  DateTime? _endTime;

  Board({required this.config, int? seed})
    : seed = seed ?? Random().nextInt(1 << 32) {
    _initializeGrid();
  }

  // Getters
  GameStatus get status => _status;
  int get flagCount => _flagCount;
  int get remainingMines => config.mines - _flagCount;
  int get rows => config.rows;
  int get cols => config.cols;
  bool get isGameOver =>
      _status == GameStatus.won || _status == GameStatus.lost;
  bool get hasStarted => _status != GameStatus.ready;
  Duration get elapsedTime {
    if (_startTime == null) return Duration.zero;
    final end = _endTime ?? DateTime.now();
    return end.difference(_startTime!);
  }

  /// Get a cell at (row, col).
  Cell getCell(int row, int col) => _grid[row][col];

  /// Initialize empty grid.
  void _initializeGrid() {
    _grid = List.generate(
      config.rows,
      (row) => List.generate(config.cols, (col) => Cell(row: row, col: col)),
    );
  }

  /// Place mines on the board, excluding the first clicked cell and its neighbors.
  void _placeMines(int safeRow, int safeCol) {
    if (_minesPlaced) return;

    final random = Random(seed);
    final safeCells = <String>{};

    // Mark safe cell and its neighbors
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        final nr = safeRow + dr;
        final nc = safeCol + dc;
        if (_isValidCell(nr, nc)) {
          safeCells.add('$nr,$nc');
        }
      }
    }

    // Place mines
    int minesPlaced = 0;
    while (minesPlaced < config.mines) {
      final row = random.nextInt(config.rows);
      final col = random.nextInt(config.cols);
      final key = '$row,$col';

      if (!safeCells.contains(key) && !_grid[row][col].isMine) {
        _grid[row][col].isMine = true;
        minesPlaced++;
      }
    }

    // Calculate adjacent mine counts
    _calculateAdjacentMines();
    _minesPlaced = true;
  }

  /// Calculate adjacent mine count for each cell.
  void _calculateAdjacentMines() {
    for (int row = 0; row < config.rows; row++) {
      for (int col = 0; col < config.cols; col++) {
        if (_grid[row][col].isMine) continue;

        int count = 0;
        for (final neighbor in _getNeighbors(row, col)) {
          if (neighbor.isMine) count++;
        }
        _grid[row][col].adjacentMines = count;
      }
    }
  }

  /// Check if cell coordinates are valid.
  bool _isValidCell(int row, int col) {
    return row >= 0 && row < config.rows && col >= 0 && col < config.cols;
  }

  /// Get all neighboring cells.
  List<Cell> _getNeighbors(int row, int col) {
    final neighbors = <Cell>[];
    for (int dr = -1; dr <= 1; dr++) {
      for (int dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        final nr = row + dr;
        final nc = col + dc;
        if (_isValidCell(nr, nc)) {
          neighbors.add(_grid[nr][nc]);
        }
      }
    }
    return neighbors;
  }

  /// Reveal a cell. Returns true if the game state changed.
  bool reveal(int row, int col) {
    if (isGameOver) return false;

    final cell = _grid[row][col];
    if (cell.isRevealed || cell.isFlagged) return false;

    // First click - place mines
    if (!_minesPlaced) {
      _placeMines(row, col);
      _status = GameStatus.playing;
      _startTime = DateTime.now();
    }

    // Reveal the cell
    cell.state = CellState.revealed;
    _revealedCount++;

    // Hit a mine - game over
    if (cell.isMine) {
      _status = GameStatus.lost;
      _endTime = DateTime.now();
      _revealAllMines();
      return true;
    }

    // Flood fill for zero cells
    if (cell.adjacentMines == 0) {
      _floodFill(row, col);
    }

    // Check win condition
    _checkWin();
    return true;
  }

  /// Flood fill to reveal adjacent cells when a zero is revealed.
  void _floodFill(int row, int col) {
    for (final neighbor in _getNeighbors(row, col)) {
      if (neighbor.isHidden && !neighbor.isFlagged) {
        neighbor.state = CellState.revealed;
        _revealedCount++;
        if (neighbor.adjacentMines == 0) {
          _floodFill(neighbor.row, neighbor.col);
        }
      }
    }
  }

  /// Reveal all mines (on game over).
  void _revealAllMines() {
    for (int row = 0; row < config.rows; row++) {
      for (int col = 0; col < config.cols; col++) {
        if (_grid[row][col].isMine) {
          _grid[row][col].state = CellState.revealed;
        }
      }
    }
  }

  /// Toggle flag on a cell.
  bool toggleFlag(int row, int col) {
    if (isGameOver) return false;
    if (!_minesPlaced) return false; // Can't flag before first reveal

    final cell = _grid[row][col];
    if (cell.isRevealed) return false;

    if (cell.isFlagged) {
      cell.state = CellState.hidden;
      _flagCount--;
    } else {
      cell.state = CellState.flagged;
      _flagCount++;
    }
    return true;
  }

  /// Chord reveal - if a revealed cell has correct number of flags around it,
  /// reveal all hidden neighbors.
  bool chordReveal(int row, int col) {
    if (isGameOver) return false;

    final cell = _grid[row][col];
    if (!cell.isRevealed || cell.adjacentMines == 0) return false;

    final neighbors = _getNeighbors(row, col);
    final flaggedCount = neighbors.where((n) => n.isFlagged).length;

    if (flaggedCount != cell.adjacentMines) return false;

    bool changed = false;
    for (final neighbor in neighbors) {
      if (neighbor.isHidden) {
        if (reveal(neighbor.row, neighbor.col)) {
          changed = true;
        }
      }
    }
    return changed;
  }

  /// Check if the player has won.
  void _checkWin() {
    final totalCells = config.rows * config.cols;
    final nonMineCells = totalCells - config.mines;

    if (_revealedCount == nonMineCells) {
      _status = GameStatus.won;
      _endTime = DateTime.now();
      // Auto-flag remaining mines
      for (int row = 0; row < config.rows; row++) {
        for (int col = 0; col < config.cols; col++) {
          final cell = _grid[row][col];
          if (cell.isMine && !cell.isFlagged) {
            cell.state = CellState.flagged;
            _flagCount++;
          }
        }
      }
    }
  }

  /// Get all cells as a flat list (for iteration).
  Iterable<Cell> get allCells sync* {
    for (int row = 0; row < config.rows; row++) {
      for (int col = 0; col < config.cols; col++) {
        yield _grid[row][col];
      }
    }
  }
}
