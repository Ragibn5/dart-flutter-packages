import 'package:flutter/material.dart';
import 'package:infinity_radio_group/infinity_radio_group.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radio Group',
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(title: const Text('Radio Group')),
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
  final _plans = const [
    PlanOption(title: 'Free', icon: Icons.rocket_launch_rounded),
    PlanOption(title: 'Pro', icon: Icons.workspace_premium_rounded),
    PlanOption(title: 'Team', icon: Icons.groups_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: InfinityRadioGroup<PlanOption>(
        uiModels: _plans,
        layoutConfig: const ListLayoutConfig(spacing: 8),
        initialSelectionIndex: 0,
        onSelectionChanged: (plan) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Selected: ${plan.title}')),
          );
        },
        cellBuilder: (model, {required selected}) => ListTile(
          leading: Icon(model.icon),
          title: Text(model.title),
          trailing: Icon(
            selected
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
          ),
        ),
      ),
    );
  }
}

class PlanOption extends RadioItemUiModel {
  final String title;
  final IconData icon;

  const PlanOption({
    required this.title,
    required this.icon,
    super.shouldBeSelected = true,
  });
}
