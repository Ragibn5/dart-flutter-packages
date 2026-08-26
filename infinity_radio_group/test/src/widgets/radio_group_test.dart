// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinity_radio_group/infinity_radio_group.dart';
import 'package:infinity_radio_group/src/widgets/radio_groups/grid_radio_group.dart';
import 'package:infinity_radio_group/src/widgets/radio_groups/list_radio_group.dart';
import 'package:infinity_radio_group/src/widgets/radio_groups/wrap_radio_group.dart';

class _TestModel extends RadioItemUiModel {
  const _TestModel();
}

void main() {
  final testModels = List.generate(3, (_) => const _TestModel());

  Widget wrap(Widget child) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: child,
    );
  }

  testWidgets(
      'InfinityRadioGroup delegates to ListRadioGroup when layout config is a ListLayoutConfig',
      (tester) async {
    const layoutConfig = ListLayoutConfig();
    await tester.pumpWidget(
      wrap(
        InfinityRadioGroup<_TestModel>(
          uiModels: testModels,
          layoutConfig: layoutConfig,
          cellBuilder: (model, {required selected}) => const SizedBox(),
          onSelectionChanged: (_) {},
        ),
      ),
    );

    expect(find.byType(ListRadioGroup<_TestModel>), findsOneWidget);
    expect(find.byType(GridRadioGroup<_TestModel>), findsNothing);
    expect(find.byType(WrapRadioGroup<_TestModel>), findsNothing);
  });

  testWidgets(
      'InfinityRadioGroup delegates to GridRadioGroup when layout config is a GridLayoutConfig',
      (tester) async {
    const layoutConfig = GridLayoutConfig();
    await tester.pumpWidget(
      wrap(
        InfinityRadioGroup<_TestModel>(
          uiModels: testModels,
          layoutConfig: layoutConfig,
          cellBuilder: (model, {required selected}) => const SizedBox(),
          onSelectionChanged: (_) {},
        ),
      ),
    );

    expect(find.byType(GridRadioGroup<_TestModel>), findsOneWidget);
    expect(find.byType(ListRadioGroup<_TestModel>), findsNothing);
    expect(find.byType(WrapRadioGroup<_TestModel>), findsNothing);
  });

  testWidgets(
      'InfinityRadioGroup delegates to WrapRadioGroup when layout config is a WrapLayoutConfig',
      (tester) async {
    const layoutConfig = WrapLayoutConfig();
    await tester.pumpWidget(
      wrap(
        InfinityRadioGroup<_TestModel>(
          uiModels: testModels,
          layoutConfig: layoutConfig,
          cellBuilder: (model, {required selected}) => const SizedBox(),
          onSelectionChanged: (_) {},
        ),
      ),
    );

    expect(find.byType(WrapRadioGroup<_TestModel>), findsOneWidget);
    expect(find.byType(ListRadioGroup<_TestModel>), findsNothing);
    expect(find.byType(GridRadioGroup<_TestModel>), findsNothing);
  });

  testWidgets(
    'InfinityRadioGroup passes leading, trailing, and initial selection correctly to ListRadioGroup',
    (tester) async {
      const layoutConfig = ListLayoutConfig();
      final leading = [const SizedBox(key: Key('leading'))];
      final trailing = [const SizedBox(key: Key('trailing'))];
      const initialIndex = 1;
      void onSelectionChanged(_) {}
      Widget cellBuilder(model, {required selected}) => const SizedBox();

      await tester.pumpWidget(
        wrap(
          InfinityRadioGroup<_TestModel>(
            uiModels: testModels,
            layoutConfig: layoutConfig,
            initialSelectionIndex: initialIndex,
            onSelectionChanged: onSelectionChanged,
            leadingWidgets: leading,
            trailingWidgets: trailing,
            cellBuilder: cellBuilder,
          ),
        ),
      );

      final listGroup = tester.widget<ListRadioGroup<_TestModel>>(
        find.byType(ListRadioGroup<_TestModel>),
      );
      expect(listGroup.uiModels, testModels);
      expect(listGroup.layoutConfig, layoutConfig);
      expect(listGroup.initialSelectionIndex, initialIndex);
      expect(listGroup.onSelectionChanged, onSelectionChanged);
      expect(listGroup.leadingWidgets, leading);
      expect(listGroup.trailingWidgets, trailing);
      expect(listGroup.cellBuilder, cellBuilder);
    },
  );

  testWidgets(
    'InfinityRadioGroup passes leading, trailing, and initial selection correctly to GridRadioGroup',
    (tester) async {
      const layoutConfig = GridLayoutConfig();
      final leading = [const SizedBox(key: Key('leading'))];
      final trailing = [const SizedBox(key: Key('trailing'))];
      const initialIndex = 1;
      void onSelectionChanged(_) {}
      Widget cellBuilder(model, {required selected}) => const SizedBox();

      await tester.pumpWidget(
        wrap(
          InfinityRadioGroup<_TestModel>(
            uiModels: testModels,
            layoutConfig: layoutConfig,
            initialSelectionIndex: initialIndex,
            onSelectionChanged: onSelectionChanged,
            leadingWidgets: leading,
            trailingWidgets: trailing,
            cellBuilder: cellBuilder,
          ),
        ),
      );

      final listGroup = tester.widget<GridRadioGroup<_TestModel>>(
        find.byType(GridRadioGroup<_TestModel>),
      );
      expect(listGroup.uiModels, testModels);
      expect(listGroup.layoutConfig, layoutConfig);
      expect(listGroup.initialSelectionIndex, initialIndex);
      expect(listGroup.onSelectionChanged, onSelectionChanged);
      expect(listGroup.leadingWidgets, leading);
      expect(listGroup.trailingWidgets, trailing);
      expect(listGroup.cellBuilder, cellBuilder);
    },
  );

  testWidgets(
    'InfinityRadioGroup passes leading, trailing, and initial selection correctly to WrapRadioGroup',
    (tester) async {
      const layoutConfig = WrapLayoutConfig();
      final leading = [const SizedBox(key: Key('leading'))];
      final trailing = [const SizedBox(key: Key('trailing'))];
      const initialIndex = 1;
      void onSelectionChanged(_) {}
      Widget cellBuilder(model, {required selected}) => const SizedBox();

      await tester.pumpWidget(
        wrap(
          InfinityRadioGroup<_TestModel>(
            uiModels: testModels,
            layoutConfig: layoutConfig,
            initialSelectionIndex: initialIndex,
            onSelectionChanged: onSelectionChanged,
            leadingWidgets: leading,
            trailingWidgets: trailing,
            cellBuilder: cellBuilder,
          ),
        ),
      );

      final listGroup = tester.widget<WrapRadioGroup<_TestModel>>(
        find.byType(WrapRadioGroup<_TestModel>),
      );
      expect(listGroup.uiModels, testModels);
      expect(listGroup.layoutConfig, layoutConfig);
      expect(listGroup.initialSelectionIndex, initialIndex);
      expect(listGroup.onSelectionChanged, onSelectionChanged);
      expect(listGroup.leadingWidgets, leading);
      expect(listGroup.trailingWidgets, trailing);
      expect(listGroup.cellBuilder, cellBuilder);
    },
  );
}
