import 'package:flutter/foundation.dart';
import '../game/difficulty.dart';

/// Provider for game settings that persist across games.
class SettingsProvider extends ChangeNotifier {
  bool _noGuessMode = false;
  GameConfig _selectedConfig = GameConfig.beginner;
  int _customRows = 10;
  int _customCols = 10;
  int _customMines = 15;
  int _holdDelayMs = 150; // Default 150ms
  bool _lockMode = false; // When true, only pan/zoom, no cell interaction

  // Getters
  bool get noGuessMode => _noGuessMode;
  GameConfig get selectedConfig => _selectedConfig;
  int get customRows => _customRows;
  int get customCols => _customCols;
  int get customMines => _customMines;
  int get holdDelayMs => _holdDelayMs;
  Duration get holdDelay => Duration(milliseconds: _holdDelayMs);
  bool get lockMode => _lockMode;

  void setNoGuessMode(bool value) {
    _noGuessMode = value;
    notifyListeners();
  }

  void setHoldDelayMs(int value) {
    _holdDelayMs = value.clamp(50, 500);
    notifyListeners();
  }

  void setLockMode(bool value) {
    _lockMode = value;
    notifyListeners();
  }

  void toggleLockMode() {
    _lockMode = !_lockMode;
    notifyListeners();
  }

  void setDifficulty(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.beginner:
        _selectedConfig = GameConfig.beginner;
        break;
      case Difficulty.intermediate:
        _selectedConfig = GameConfig.intermediate;
        break;
      case Difficulty.expert:
        _selectedConfig = GameConfig.expert;
        break;
      case Difficulty.custom:
        _selectedConfig = GameConfig.custom(
          rows: _customRows,
          cols: _customCols,
          mines: _customMines,
        );
        break;
    }
    notifyListeners();
  }

  void setCustomGrid({int? rows, int? cols, int? mines}) {
    if (rows != null) _customRows = rows.clamp(5, 30);
    if (cols != null) _customCols = cols.clamp(5, 30);
    if (mines != null) {
      final maxMines = (_customRows * _customCols * 0.8).floor();
      _customMines = mines.clamp(1, maxMines);
    }
    
    if (_selectedConfig.difficulty == Difficulty.custom) {
      _selectedConfig = GameConfig.custom(
        rows: _customRows,
        cols: _customCols,
        mines: _customMines,
      );
    }
    notifyListeners();
  }

  /// Get the current config to start a game with.
  GameConfig get currentGameConfig => _selectedConfig;
}
