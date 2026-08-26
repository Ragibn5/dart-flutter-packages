import 'package:flutter/material.dart';
import 'package:infinity_radio_group/infinity_radio_group.dart' as radio_group;

import 'package:example/widgets/demo_option.dart';
import 'package:example/widgets/option_tile.dart';

class LayoutDemo extends StatelessWidget {
  final radio_group.RadioGroupLayoutConfig layoutConfig;
  final DemoOption? selected;
  final ValueChanged<DemoOption> onSelectionChanged;

  const LayoutDemo({
    super.key,
    required this.layoutConfig,
    required this.selected,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tileStyle = switch (layoutConfig) {
      radio_group.ListLayoutConfig() => OptionTileStyle.list,
      radio_group.GridLayoutConfig() => OptionTileStyle.grid,
      radio_group.WrapLayoutConfig() => OptionTileStyle.wrap,
    };

    final selectedIndex = selected == null
        ? 0
        : demoOptions.indexOf(selected!);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      children: [
        radio_group.InfinityRadioGroup<DemoOption>(
          key: ValueKey(selectedIndex),
          uiModels: demoOptions,
          layoutConfig: layoutConfig,
          initialSelectionIndex: selectedIndex,
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
