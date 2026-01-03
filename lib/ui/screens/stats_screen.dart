import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/stats_database.dart';
import '../../data/csv_exporter.dart';

/// Statistics screen showing game history and stats.
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String? _selectedDifficulty;
  List<GameRecord> _games = [];
  StatsSummary? _summary;
  bool _isLoading = true;

  final _difficulties = ['All', 'Beginner', 'Intermediate', 'Expert', 'Custom'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final db = StatsDatabase.instance;
    final difficulty = _selectedDifficulty == 'All'
        ? null
        : _selectedDifficulty;

    final games = difficulty == null
        ? await db.getAllGames()
        : await db.getGamesByDifficulty(difficulty);
    final summary = await db.getStatsSummary(difficulty: difficulty);

    setState(() {
      _games = games;
      _summary = summary;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Export to CSV',
            onPressed: _games.isEmpty ? null : _exportStats,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter by difficulty',
            onSelected: (value) {
              setState(() {
                _selectedDifficulty = value == 'All' ? null : value;
              });
              _loadData();
            },
            itemBuilder: (context) => _difficulties
                .map((d) => PopupMenuItem(value: d, child: Text(d)))
                .toList(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildSummaryCard()),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Game History',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                  _games.isEmpty
                      ? const SliverFillRemaining(
                          child: Center(child: Text('No games played yet!')),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildGameTile(_games[index]),
                            childCount: _games.length,
                          ),
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    final summary = _summary;
    if (summary == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _selectedDifficulty ?? 'All Difficulties',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Games', summary.totalGames.toString()),
                _buildStatItem('Wins', summary.gamesWon.toString()),
                _buildStatItem('Win Rate', summary.winRatePercentage),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Best Time',
                  summary.bestTimeFormatted ?? '--:--',
                ),
                _buildStatItem(
                  'Avg Time',
                  summary.averageTimeFormatted ?? '--:--',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildGameTile(GameRecord game) {
    final dateFormat = DateFormat('MMM d, yyyy HH:mm');
    final duration = Duration(seconds: game.durationSeconds);
    final timeStr =
        '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';

    return ListTile(
      leading: Icon(
        game.won ? Icons.emoji_events : Icons.close,
        color: game.won ? Colors.amber : Colors.red,
      ),
      title: Text(game.difficulty),
      subtitle: Text('${game.rows}x${game.cols} • ${game.mines} mines'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(timeStr, style: Theme.of(context).textTheme.bodyLarge),
          Text(
            dateFormat.format(game.timestamp),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Future<void> _exportStats() async {
    try {
      await CsvExporter.exportAndShare(_games);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stats exported successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }
}
