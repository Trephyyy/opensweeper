import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// SQLite database helper for game statistics.
class StatsDatabase {
  static const _databaseName = 'opensweeper_stats.db';
  static const _databaseVersion = 1;

  static const tableGames = 'games';

  // Column names
  static const columnId = 'id';
  static const columnDifficulty = 'difficulty';
  static const columnRows = 'rows';
  static const columnCols = 'cols';
  static const columnMines = 'mines';
  static const columnWon = 'won';
  static const columnDurationSeconds = 'duration_seconds';
  static const columnTimestamp = 'timestamp';
  static const columnSeed = 'seed';

  // Singleton pattern
  StatsDatabase._privateConstructor();
  static final StatsDatabase instance = StatsDatabase._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableGames (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnDifficulty TEXT NOT NULL,
        $columnRows INTEGER NOT NULL,
        $columnCols INTEGER NOT NULL,
        $columnMines INTEGER NOT NULL,
        $columnWon INTEGER NOT NULL,
        $columnDurationSeconds INTEGER NOT NULL,
        $columnTimestamp TEXT NOT NULL,
        $columnSeed INTEGER NOT NULL
      )
    ''');
  }

  /// Insert a game record.
  Future<int> insertGame(GameRecord record) async {
    final db = await database;
    return await db.insert(tableGames, record.toMap());
  }

  /// Get all game records.
  Future<List<GameRecord>> getAllGames() async {
    final db = await database;
    final maps = await db.query(
      tableGames,
      orderBy: '$columnTimestamp DESC',
    );
    return maps.map((map) => GameRecord.fromMap(map)).toList();
  }

  /// Get games filtered by difficulty.
  Future<List<GameRecord>> getGamesByDifficulty(String difficulty) async {
    final db = await database;
    final maps = await db.query(
      tableGames,
      where: '$columnDifficulty = ?',
      whereArgs: [difficulty],
      orderBy: '$columnTimestamp DESC',
    );
    return maps.map((map) => GameRecord.fromMap(map)).toList();
  }

  /// Get statistics summary.
  Future<StatsSummary> getStatsSummary({String? difficulty}) async {
    final db = await database;

    String whereClause = '';
    List<dynamic> whereArgs = [];
    if (difficulty != null) {
      whereClause = 'WHERE $columnDifficulty = ?';
      whereArgs = [difficulty];
    }

    // Total games
    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableGames $whereClause',
      whereArgs,
    );
    final totalGames = totalResult.first['count'] as int;

    // Won games
    final wonClause = whereClause.isEmpty
        ? 'WHERE $columnWon = 1'
        : '$whereClause AND $columnWon = 1';
    final wonResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableGames $wonClause',
      whereArgs,
    );
    final gamesWon = wonResult.first['count'] as int;

    // Best time (won games only)
    final bestTimeResult = await db.rawQuery(
      'SELECT MIN($columnDurationSeconds) as best FROM $tableGames $wonClause',
      whereArgs,
    );
    final bestTime = bestTimeResult.first['best'] as int?;

    // Average time (won games only)
    final avgTimeResult = await db.rawQuery(
      'SELECT AVG($columnDurationSeconds) as avg FROM $tableGames $wonClause',
      whereArgs,
    );
    final avgTime = avgTimeResult.first['avg'] as double?;

    return StatsSummary(
      totalGames: totalGames,
      gamesWon: gamesWon,
      gamesLost: totalGames - gamesWon,
      winRate: totalGames > 0 ? gamesWon / totalGames : 0,
      bestTimeSeconds: bestTime,
      averageTimeSeconds: avgTime?.round(),
    );
  }

  /// Delete all game records.
  Future<int> deleteAllGames() async {
    final db = await database;
    return await db.delete(tableGames);
  }

  /// Close the database.
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}

/// Represents a single game record.
class GameRecord {
  final int? id;
  final String difficulty;
  final int rows;
  final int cols;
  final int mines;
  final bool won;
  final int durationSeconds;
  final DateTime timestamp;
  final int seed;

  GameRecord({
    this.id,
    required this.difficulty,
    required this.rows,
    required this.cols,
    required this.mines,
    required this.won,
    required this.durationSeconds,
    required this.timestamp,
    required this.seed,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) StatsDatabase.columnId: id,
      StatsDatabase.columnDifficulty: difficulty,
      StatsDatabase.columnRows: rows,
      StatsDatabase.columnCols: cols,
      StatsDatabase.columnMines: mines,
      StatsDatabase.columnWon: won ? 1 : 0,
      StatsDatabase.columnDurationSeconds: durationSeconds,
      StatsDatabase.columnTimestamp: timestamp.toIso8601String(),
      StatsDatabase.columnSeed: seed,
    };
  }

  factory GameRecord.fromMap(Map<String, dynamic> map) {
    return GameRecord(
      id: map[StatsDatabase.columnId] as int?,
      difficulty: map[StatsDatabase.columnDifficulty] as String,
      rows: map[StatsDatabase.columnRows] as int,
      cols: map[StatsDatabase.columnCols] as int,
      mines: map[StatsDatabase.columnMines] as int,
      won: (map[StatsDatabase.columnWon] as int) == 1,
      durationSeconds: map[StatsDatabase.columnDurationSeconds] as int,
      timestamp: DateTime.parse(map[StatsDatabase.columnTimestamp] as String),
      seed: map[StatsDatabase.columnSeed] as int,
    );
  }

  /// Convert to CSV row.
  List<dynamic> toCsvRow() {
    return [
      id,
      difficulty,
      rows,
      cols,
      mines,
      won ? 'Yes' : 'No',
      durationSeconds,
      timestamp.toIso8601String(),
      seed,
    ];
  }

  /// CSV header row.
  static List<String> get csvHeaders => [
    'ID',
    'Difficulty',
    'Rows',
    'Cols',
    'Mines',
    'Won',
    'Duration (seconds)',
    'Timestamp',
    'Seed',
  ];
}

/// Statistics summary.
class StatsSummary {
  final int totalGames;
  final int gamesWon;
  final int gamesLost;
  final double winRate;
  final int? bestTimeSeconds;
  final int? averageTimeSeconds;

  StatsSummary({
    required this.totalGames,
    required this.gamesWon,
    required this.gamesLost,
    required this.winRate,
    this.bestTimeSeconds,
    this.averageTimeSeconds,
  });

  String get winRatePercentage => '${(winRate * 100).toStringAsFixed(1)}%';

  String? get bestTimeFormatted {
    if (bestTimeSeconds == null) return null;
    final mins = bestTimeSeconds! ~/ 60;
    final secs = bestTimeSeconds! % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String? get averageTimeFormatted {
    if (averageTimeSeconds == null) return null;
    final mins = averageTimeSeconds! ~/ 60;
    final secs = averageTimeSeconds! % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
