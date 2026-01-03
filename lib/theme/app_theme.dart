import 'package:flutter/material.dart';

/// App theme configuration with OG Minesweeper inspired colors.
class AppTheme {
  // Classic Minesweeper number colors
  static const numberColors = [
    Colors.transparent, // 0 - not shown
    Color(0xFF0000FF), // 1 - blue
    Color(0xFF008000), // 2 - green
    Color(0xFFFF0000), // 3 - red
    Color(0xFF000080), // 4 - dark blue
    Color(0xFF800000), // 5 - maroon
    Color(0xFF008080), // 6 - teal
    Color(0xFF000000), // 7 - black
    Color(0xFF808080), // 8 - gray
  ];

  /// Get the light theme.
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFC0C0C0),
        brightness: Brightness.light,
      ).copyWith(surface: const Color(0xFFC0C0C0), onSurface: Colors.black),
      scaffoldBackgroundColor: const Color(0xFFE0E0E0),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFC0C0C0),
        foregroundColor: Colors.black,
        elevation: 2,
      ),
      cardTheme: const CardThemeData(color: Color(0xFFC0C0C0), elevation: 2),
      extensions: const [
        MinesweeperTheme(
          cellHidden: Color(0xFFC0C0C0),
          cellRevealed: Color(0xFFBDBDBD),
          cellHighlight: Color(0xFFFFFFFF),
          cellShadow: Color(0xFF808080),
          mine: Colors.black,
          flag: Colors.red,
          wrongFlag: Colors.orange,
        ),
      ],
    );
  }

  /// Get the dark theme.
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF424242),
        brightness: Brightness.dark,
      ).copyWith(surface: const Color(0xFF303030), onSurface: Colors.white),
      scaffoldBackgroundColor: const Color(0xFF212121),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF303030),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      cardTheme: const CardThemeData(color: Color(0xFF424242), elevation: 2),
      extensions: const [
        MinesweeperTheme(
          cellHidden: Color(0xFF505050),
          cellRevealed: Color(0xFF383838),
          cellHighlight: Color(0xFF686868),
          cellShadow: Color(0xFF282828),
          mine: Colors.white,
          flag: Color(0xFFFF6B6B),
          wrongFlag: Color(0xFFFFAB40),
        ),
      ],
    );
  }
}

/// Custom theme extension for Minesweeper-specific colors.
class MinesweeperTheme extends ThemeExtension<MinesweeperTheme> {
  final Color cellHidden;
  final Color cellRevealed;
  final Color cellHighlight;
  final Color cellShadow;
  final Color mine;
  final Color flag;
  final Color wrongFlag;

  const MinesweeperTheme({
    required this.cellHidden,
    required this.cellRevealed,
    required this.cellHighlight,
    required this.cellShadow,
    required this.mine,
    required this.flag,
    required this.wrongFlag,
  });

  @override
  MinesweeperTheme copyWith({
    Color? cellHidden,
    Color? cellRevealed,
    Color? cellHighlight,
    Color? cellShadow,
    Color? mine,
    Color? flag,
    Color? wrongFlag,
  }) {
    return MinesweeperTheme(
      cellHidden: cellHidden ?? this.cellHidden,
      cellRevealed: cellRevealed ?? this.cellRevealed,
      cellHighlight: cellHighlight ?? this.cellHighlight,
      cellShadow: cellShadow ?? this.cellShadow,
      mine: mine ?? this.mine,
      flag: flag ?? this.flag,
      wrongFlag: wrongFlag ?? this.wrongFlag,
    );
  }

  @override
  MinesweeperTheme lerp(ThemeExtension<MinesweeperTheme>? other, double t) {
    if (other is! MinesweeperTheme) return this;
    return MinesweeperTheme(
      cellHidden: Color.lerp(cellHidden, other.cellHidden, t)!,
      cellRevealed: Color.lerp(cellRevealed, other.cellRevealed, t)!,
      cellHighlight: Color.lerp(cellHighlight, other.cellHighlight, t)!,
      cellShadow: Color.lerp(cellShadow, other.cellShadow, t)!,
      mine: Color.lerp(mine, other.mine, t)!,
      flag: Color.lerp(flag, other.flag, t)!,
      wrongFlag: Color.lerp(wrongFlag, other.wrongFlag, t)!,
    );
  }
}

extension MinesweeperThemeExtension on ThemeData {
  MinesweeperTheme get minesweeper =>
      extension<MinesweeperTheme>() ??
      const MinesweeperTheme(
        cellHidden: Color(0xFFC0C0C0),
        cellRevealed: Color(0xFFBDBDBD),
        cellHighlight: Color(0xFFFFFFFF),
        cellShadow: Color(0xFF808080),
        mine: Colors.black,
        flag: Colors.red,
        wrongFlag: Colors.orange,
      );
}
