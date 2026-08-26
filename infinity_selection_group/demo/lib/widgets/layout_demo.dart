import 'package:flutter/material.dart';
import 'package:infinity_selection_group/infinity_selection_group.dart'
    as selection_group;

import 'package:example/widgets/demo_option.dart';
import 'package:example/widgets/option_tile.dart';

class LayoutDemo extends StatelessWidget {
  final selection_group.SelectionGroupLayoutConfig layoutConfig;
  final List<int> selectedIndices;
  final int maxSelectionCount;
  final ValueChanged<List<int>> onSelectionChanged;
  final VoidCallback onSelectionOverflow;

  const LayoutDemo({
    super.key,
    required this.layoutConfig,
    required this.selectedIndices,
    required this.maxSelectionCount,
    required this.onSelectionChanged,
    required this.onSelectionOverflow,
  });

  @override
  Widget build(BuildContext context) {
    final tileStyle = switch (layoutConfig) {
      selection_group.ListLayoutConfig() => OptionTileStyle.list,
      selection_group.GridLayoutConfig() => OptionTileStyle.grid,
      selection_group.WrapLayoutConfig() => OptionTileStyle.wrap,
    };

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      children: [
        selection_group.InfinitySelectionGroup<DemoOption>(
          key: ValueKey(selectedIndices.join(',')),
          uiModels: demoOptions,
          layoutConfig: layoutConfig,
          initialSelectionIndices: selectedIndices,
          maxSelectionCount: maxSelectionCount,
          onSelectionOverflow: onSelectionOverflow,
          onSelectionChanged: onSelectionChanged,
          cellBuilder: (model, {required selected}) => OptionTile(
            model: model,
            selected: selected,
            style: tileStyle,
          ),
        ),
      ],
    );
  }
}
