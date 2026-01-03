import 'dart:async';
import 'package:flutter/foundation.dart';
import 'board.dart';
import 'difficulty.dart';

/// Provider for game state management.
class GameProvider extends ChangeNotifier {
  Board _board;
  Timer? _timer;
  int _secondsElapsed = 0;

  GameProvider({GameConfig? config})
    : _board = Board(config: config ?? GameConfig.beginner);

  // Getters
  Board get board => _board;
  GameConfig get config => _board.config;
  GameStatus get status => _board.status;
  int get remainingMines => _board.remainingMines;
  int get secondsElapsed => _secondsElapsed;
  bool get isGameOver => _board.isGameOver;

  /// Start a new game with the given configuration.
  void newGame({GameConfig? config}) {
    _timer?.cancel();
    _secondsElapsed = 0;
    _board = Board(config: config ?? _board.config);
    notifyListeners();
  }

  /// Reveal a cell.
  void reveal(int row, int col) {
    final wasReady = _board.status == GameStatus.ready;
    final changed = _board.reveal(row, col);

    if (wasReady && _board.status == GameStatus.playing) {
      _startTimer();
    }

    if (_board.isGameOver) {
      _timer?.cancel();
    }

    if (changed) {
      notifyListeners();
    }
  }

  /// Toggle flag on a cell.
  void toggleFlag(int row, int col) {
    if (_board.toggleFlag(row, col)) {
      notifyListeners();
    }
  }

  /// Chord reveal (double-tap on revealed cell).
  void chordReveal(int row, int col) {
    if (_board.chordReveal(row, col)) {
      notifyListeners();
    }
  }

  /// Start the game timer.
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _secondsElapsed++;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
