/// Represents the state of a single cell on the board.
enum CellState { hidden, revealed, flagged }

/// A single cell in the Minesweeper grid.
class Cell {
  final int row;
  final int col;
  bool isMine;
  int adjacentMines;
  CellState state;

  Cell({
    required this.row,
    required this.col,
    this.isMine = false,
    this.adjacentMines = 0,
    this.state = CellState.hidden,
  });

  bool get isRevealed => state == CellState.revealed;
  bool get isFlagged => state == CellState.flagged;
  bool get isHidden => state == CellState.hidden;

  Cell copyWith({bool? isMine, int? adjacentMines, CellState? state}) {
    return Cell(
      row: row,
      col: col,
      isMine: isMine ?? this.isMine,
      adjacentMines: adjacentMines ?? this.adjacentMines,
      state: state ?? this.state,
    );
  }
}
