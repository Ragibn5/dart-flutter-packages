import 'package:flutter/widgets.dart';
import 'package:infinity_radio_group/src/configs/radio_group_layout_config.dart';
import 'package:infinity_radio_group/src/models/radio_item_ui_model.dart';
import 'package:infinity_radio_group/src/widgets/radio_groups/grid_radio_group.dart';
import 'package:infinity_radio_group/src/widgets/radio_groups/list_radio_group.dart';
import 'package:infinity_radio_group/src/widgets/radio_groups/wrap_radio_group.dart';

class InfinityRadioGroup<T extends RadioItemUiModel> extends StatelessWidget {
  final List<T> uiModels;
  final RadioGroupLayoutConfig layoutConfig;
  final int? initialSelectionIndex;
  final void Function(T selectedModel) onSelectionChanged;
  final List<Widget> leadingWidgets;
  final List<Widget> trailingWidgets;
  final Widget Function(T model, {required bool selected}) cellBuilder;

  const InfinityRadioGroup({
    super.key,
    required this.uiModels,
    required this.layoutConfig,
    this.initialSelectionIndex,
    required this.onSelectionChanged,
    this.leadingWidgets = const [],
    this.trailingWidgets = const [],
    required this.cellBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return switch (layoutConfig) {
      ListLayoutConfig() => ListRadioGroup(
          uiModels: uiModels,
          layoutConfig: layoutConfig as ListLayoutConfig,
          initialSelectionIndex: initialSelectionIndex,
          onSelectionChanged: onSelectionChanged,
          leadingWidgets: leadingWidgets,
          trailingWidgets: trailingWidgets,
          cellBuilder: cellBuilder,
        ),
      GridLayoutConfig() => GridRadioGroup(
          uiModels: uiModels,
          layoutConfig: layoutConfig as GridLayoutConfig,
          initialSelectionIndex: initialSelectionIndex,
          onSelectionChanged: onSelectionChanged,
          leadingWidgets: leadingWidgets,
          trailingWidgets: trailingWidgets,
          cellBuilder: cellBuilder,
        ),
      WrapLayoutConfig() => WrapRadioGroup(
          uiModels: uiModels,
          layoutConfig: layoutConfig as WrapLayoutConfig,
          initialSelectionIndex: initialSelectionIndex,
          onSelectionChanged: onSelectionChanged,
          leadingWidgets: leadingWidgets,
          trailingWidgets: trailingWidgets,
          cellBuilder: cellBuilder,
        )
    };
  }
}
