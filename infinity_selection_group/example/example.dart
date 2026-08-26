import 'package:flutter/material.dart';
import 'package:infinity_selection_group/infinity_selection_group.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Selection Group',
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(title: const Text('Selection Group')),
        body: const _LayoutPicker(),
      ),
    );
  }
}

class _LayoutPicker extends StatefulWidget {
  const _LayoutPicker();

  @override
  State<_LayoutPicker> createState() => _LayoutPickerState();
}

class _LayoutPickerState extends State<_LayoutPicker> {
  static const _maxSelectionCount = 3;

  final _plans = const [
    PlanOption(title: 'Free', icon: Icons.rocket_launch_rounded),
    PlanOption(title: 'Pro', icon: Icons.workspace_premium_rounded),
    PlanOption(title: 'Team', icon: Icons.groups_rounded),
    PlanOption(title: 'Enterprise', icon: Icons.business_center_rounded),
  ];

  var _selectedIndices = <int>[0];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected (${_selectedIndices.length}/$_maxSelectionCount): '
            '${_selectedIndices.isEmpty ? 'None' : _selectedIndices}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          InfinitySelectionGroup<PlanOption>(
            uiModels: _plans,
            layoutConfig: const ListLayoutConfig(spacing: 8),
            maxSelectionCount: _maxSelectionCount,
            initialSelectionIndices: _selectedIndices,
            onSelectionChanged: (indices) {
              setState(() => _selectedIndices = indices);
            },
            onSelectionOverflow: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('You can select up to 3 items at once.'),
                ),
              );
            },
            cellBuilder: (model, {required selected}) => ListTile(
              leading: Icon(model.icon),
              title: Text(model.title),
              trailing: Icon(
                selected
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PlanOption extends SelectionItemUiModel {
  final String title;
  final IconData icon;

  const PlanOption({
    required this.title,
    required this.icon,
    super.shouldBeSelected = true,
  });
}
