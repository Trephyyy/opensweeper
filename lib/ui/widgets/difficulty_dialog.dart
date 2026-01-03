import 'package:flutter/material.dart';
import '../../game/difficulty.dart';

/// Dialog for selecting game difficulty.
class DifficultyDialog extends StatefulWidget {
  final GameConfig currentConfig;
  final void Function(GameConfig) onSelect;

  const DifficultyDialog({
    super.key,
    required this.currentConfig,
    required this.onSelect,
  });

  @override
  State<DifficultyDialog> createState() => _DifficultyDialogState();
}

class _DifficultyDialogState extends State<DifficultyDialog> {
  late Difficulty _selected;
  late int _customRows;
  late int _customCols;
  late int _customMines;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentConfig.difficulty;
    _customRows = widget.currentConfig.rows;
    _customCols = widget.currentConfig.cols;
    _customMines = widget.currentConfig.mines;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Difficulty'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOption('Beginner', '9×9, 10 mines', Difficulty.beginner),
            _buildOption(
              'Intermediate',
              '16×16, 40 mines',
              Difficulty.intermediate,
            ),
            _buildOption('Expert', '16×30, 99 mines', Difficulty.expert),
            _buildOption(
              'Custom',
              '$_customRows×$_customCols, $_customMines mines',
              Difficulty.custom,
            ),
            if (_selected == Difficulty.custom) _buildCustomInputs(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _onConfirm, child: const Text('Start')),
      ],
    );
  }

  Widget _buildOption(String title, String subtitle, Difficulty difficulty) {
    return RadioListTile<Difficulty>(
      title: Text(title),
      subtitle: Text(subtitle),
      value: difficulty,
      groupValue: _selected,
      onChanged: (value) {
        if (value != null) {
          setState(() => _selected = value);
        }
      },
    );
  }

  Widget _buildCustomInputs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Rows',
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: '$_customRows'),
                  onChanged: (v) =>
                      _customRows = int.tryParse(v) ?? _customRows,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Columns',
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: '$_customCols'),
                  onChanged: (v) =>
                      _customCols = int.tryParse(v) ?? _customCols,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Mines',
              isDense: true,
            ),
            keyboardType: TextInputType.number,
            controller: TextEditingController(text: '$_customMines'),
            onChanged: (v) => _customMines = int.tryParse(v) ?? _customMines,
          ),
        ],
      ),
    );
  }

  void _onConfirm() {
    GameConfig config;
    switch (_selected) {
      case Difficulty.beginner:
        config = GameConfig.beginner;
        break;
      case Difficulty.intermediate:
        config = GameConfig.intermediate;
        break;
      case Difficulty.expert:
        config = GameConfig.expert;
        break;
      case Difficulty.custom:
        config = GameConfig.custom(
          rows: _customRows,
          cols: _customCols,
          mines: _customMines,
        );
        break;
    }
    widget.onSelect(config);
    Navigator.of(context).pop();
  }
}
