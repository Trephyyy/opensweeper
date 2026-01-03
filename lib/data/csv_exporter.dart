import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'stats_database.dart';

/// Utility for exporting stats to CSV.
class CsvExporter {
  /// Export all games to a CSV file and return the file path.
  static Future<String> exportToCsv(List<GameRecord> games) async {
    // Build CSV data
    final rows = <List<dynamic>>[
      GameRecord.csvHeaders,
      ...games.map((g) => g.toCsvRow()),
    ];

    final csv = const ListToCsvConverter().convert(rows);

    // Get documents directory
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final fileName = 'opensweeper_stats_$timestamp.csv';
    final filePath = '${directory.path}/$fileName';

    // Write file
    final file = File(filePath);
    await file.writeAsString(csv);

    return filePath;
  }

  /// Export and share the CSV file.
  static Future<void> exportAndShare(List<GameRecord> games) async {
    final filePath = await exportToCsv(games);
    await Share.shareXFiles(
      [XFile(filePath)],
      text: 'OpenSweeper Statistics',
    );
  }

  /// Export to a specific directory (for advanced users).
  static Future<String> exportToDirectory(
    List<GameRecord> games,
    String directoryPath,
  ) async {
    final rows = <List<dynamic>>[
      GameRecord.csvHeaders,
      ...games.map((g) => g.toCsvRow()),
    ];

    final csv = const ListToCsvConverter().convert(rows);

    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final fileName = 'opensweeper_stats_$timestamp.csv';
    final filePath = '$directoryPath/$fileName';

    final file = File(filePath);
    await file.writeAsString(csv);

    return filePath;
  }
}
