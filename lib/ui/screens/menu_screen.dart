import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/settings_provider.dart';
import '../../game/difficulty.dart';
import '../../theme/theme_provider.dart';

/// Main menu screen for game setup.
class MenuScreen extends StatelessWidget {
  final VoidCallback onStartGame;

  const MenuScreen({super.key, required this.onStartGame});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenSweeper'),
        centerTitle: true,
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, theme, _) {
              return IconButton(
                icon: Icon(
                  theme.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                tooltip: 'Toggle theme',
                onPressed: theme.toggleTheme,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/opensweeper_logo.png',
                  width: 100,
                  height: 100,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'OpenSweeper',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Difficulty Selection
              Text(
                'Difficulty',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _DifficultySelector(),

              const SizedBox(height: 24),

              // Custom Grid Options
              Consumer<SettingsProvider>(
                builder: (context, settings, _) {
                  if (settings.selectedConfig.difficulty != Difficulty.custom) {
                    return const SizedBox.shrink();
                  }
                  return _CustomGridOptions();
                },
              ),

              // Game Options
              Text('Options', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _GameOptions(),

              const SizedBox(height: 32),

              // Start Button
              FilledButton.icon(
                onPressed: onStartGame,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Game'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),

              const SizedBox(height: 16),

              // Current Config Summary
              Consumer<SettingsProvider>(
                builder: (context, settings, _) {
                  final config = settings.selectedConfig;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(
                            icon: Icons.grid_on,
                            label: 'Grid',
                            value: '${config.rows}×${config.cols}',
                          ),
                          _StatItem(
                            icon: Icons.brightness_7,
                            label: 'Mines',
                            value: '${config.mines}',
                          ),
                          _StatItem(
                            icon: Icons.psychology,
                            label: 'Mode',
                            value: settings.noGuessMode
                                ? 'No-Guess'
                                : 'Classic',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultySelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final current = settings.selectedConfig.difficulty;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _DifficultyChip(
              label: 'Beginner',
              subtitle: '9×9 • 10',
              difficulty: Difficulty.beginner,
              isSelected: current == Difficulty.beginner,
              onTap: () => settings.setDifficulty(Difficulty.beginner),
            ),
            _DifficultyChip(
              label: 'Intermediate',
              subtitle: '16×16 • 40',
              difficulty: Difficulty.intermediate,
              isSelected: current == Difficulty.intermediate,
              onTap: () => settings.setDifficulty(Difficulty.intermediate),
            ),
            _DifficultyChip(
              label: 'Expert',
              subtitle: '30×16 • 99',
              difficulty: Difficulty.expert,
              isSelected: current == Difficulty.expert,
              onTap: () => settings.setDifficulty(Difficulty.expert),
            ),
            _DifficultyChip(
              label: 'Custom',
              subtitle: 'Your size',
              difficulty: Difficulty.custom,
              isSelected: current == Difficulty.custom,
              onTap: () => settings.setDifficulty(Difficulty.custom),
            ),
          ],
        );
      },
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  final String label;
  final String subtitle;
  final Difficulty difficulty;
  final bool isSelected;
  final VoidCallback onTap;

  const _DifficultyChip({
    required this.label,
    required this.subtitle,
    required this.difficulty,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}

class _CustomGridOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Card(
          margin: const EdgeInsets.only(bottom: 24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Custom Grid',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _NumberInput(
                        label: 'Rows',
                        value: settings.customRows,
                        min: 5,
                        max: 30,
                        onChanged: (v) => settings.setCustomGrid(rows: v),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _NumberInput(
                        label: 'Columns',
                        value: settings.customCols,
                        min: 5,
                        max: 30,
                        onChanged: (v) => settings.setCustomGrid(cols: v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _NumberInput(
                  label: 'Mines',
                  value: settings.customMines,
                  min: 1,
                  max: (settings.customRows * settings.customCols * 0.8)
                      .floor(),
                  onChanged: (v) => settings.setCustomGrid(mines: v),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NumberInput extends StatefulWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _NumberInput({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  State<_NumberInput> createState() => _NumberInputState();
}

class _NumberInputState extends State<_NumberInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(_NumberInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSubmitted(String text) {
    final parsed = int.tryParse(text);
    if (parsed != null) {
      final clamped = parsed.clamp(widget.min, widget.max);
      widget.onChanged(clamped);
      _controller.text = clamped.toString();
    } else {
      _controller.text = widget.value.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Row(
          children: [
            IconButton.outlined(
              icon: const Icon(Icons.remove),
              onPressed: widget.value > widget.min
                  ? () => widget.onChanged(widget.value - 1)
                  : null,
              iconSize: 18,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: '${widget.min}-${widget.max}',
                ),
                onSubmitted: _onSubmitted,
                onTapOutside: (_) {
                  _onSubmitted(_controller.text);
                  FocusScope.of(context).unfocus();
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton.outlined(
              icon: const Icon(Icons.add),
              onPressed: widget.value < widget.max
                  ? () => widget.onChanged(widget.value + 1)
                  : null,
              iconSize: 18,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ],
        ),
      ],
    );
  }
}

class _GameOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('No-Guess Mode'),
                subtitle: const Text('First click always opens a safe area'),
                value: settings.noGuessMode,
                onChanged: settings.setNoGuessMode,
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Flag Hold Delay'),
                        Text(
                          '${settings.holdDelayMs}ms',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    Slider(
                      value: settings.holdDelayMs.toDouble(),
                      min: 50,
                      max: 500,
                      divisions: 9,
                      label: '${settings.holdDelayMs}ms',
                      onChanged: (v) => settings.setHoldDelayMs(v.round()),
                    ),
                    Text(
                      'How long to hold for flagging (lower = faster)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
