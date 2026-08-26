// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinity_selection_group/infinity_selection_group.dart';
import 'package:infinity_selection_group/src/widgets/selection_groups/grid_selection_group.dart';
import 'package:infinity_selection_group/src/widgets/selection_groups/list_selection_group.dart';
import 'package:infinity_selection_group/src/widgets/selection_groups/wrap_selection_group.dart';

class _TestModel extends SelectionItemUiModel {
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
      'InfinitySelectionGroup delegates to ListSelectionGroup when layout config is a ListLayoutConfig',
      (tester) async {
    const layoutConfig = ListLayoutConfig();
    await tester.pumpWidget(
      wrap(
        InfinitySelectionGroup<_TestModel>(
          uiModels: testModels,
          layoutConfig: layoutConfig,
          cellBuilder: (model, {required selected}) => const SizedBox(),
          onSelectionChanged: (_) {},
        ),
      ),
    );

    expect(find.byType(ListSelectionGroup<_TestModel>), findsOneWidget);
    expect(find.byType(GridSelectionGroup<_TestModel>), findsNothing);
    expect(find.byType(WrapSelectionGroup<_TestModel>), findsNothing);
  });

  testWidgets(
      'InfinitySelectionGroup delegates to GridSelectionGroup when layout config is a GridLayoutConfig',
      (tester) async {
    const layoutConfig = GridLayoutConfig();
    await tester.pumpWidget(
      wrap(
        InfinitySelectionGroup<_TestModel>(
          uiModels: testModels,
          layoutConfig: layoutConfig,
          cellBuilder: (model, {required selected}) => const SizedBox(),
          onSelectionChanged: (_) {},
        ),
      ),
    );

    expect(find.byType(GridSelectionGroup<_TestModel>), findsOneWidget);
    expect(find.byType(ListSelectionGroup<_TestModel>), findsNothing);
    expect(find.byType(WrapSelectionGroup<_TestModel>), findsNothing);
  });

  testWidgets(
      'InfinitySelectionGroup delegates to WrapSelectionGroup when layout config is a WrapLayoutConfig',
      (tester) async {
    const layoutConfig = WrapLayoutConfig();
    await tester.pumpWidget(
      wrap(
        InfinitySelectionGroup<_TestModel>(
          uiModels: testModels,
          layoutConfig: layoutConfig,
          cellBuilder: (model, {required selected}) => const SizedBox(),
          onSelectionChanged: (_) {},
        ),
      ),
    );

    expect(find.byType(WrapSelectionGroup<_TestModel>), findsOneWidget);
    expect(find.byType(ListSelectionGroup<_TestModel>), findsNothing);
    expect(find.byType(GridSelectionGroup<_TestModel>), findsNothing);
  });

  testWidgets(
    'InfinitySelectionGroup passes parameters correctly to ListSelectionGroup',
    (tester) async {
      const layoutConfig = ListLayoutConfig();
      final leading = [const SizedBox(key: Key('leading'))];
      final trailing = [const SizedBox(key: Key('trailing'))];
      const initialIndices = [1];
      const maxSelectionCount = 2;
      void onSelectionChanged(_) {}
      void onSelectionOverflow() {}
      Widget cellBuilder(model, {required selected}) => const SizedBox();

      await tester.pumpWidget(
        wrap(
          InfinitySelectionGroup<_TestModel>(
            uiModels: testModels,
            layoutConfig: layoutConfig,
            initialSelectionIndices: initialIndices,
            maxSelectionCount: maxSelectionCount,
            onSelectionOverflow: onSelectionOverflow,
            onSelectionChanged: onSelectionChanged,
            leadingWidgets: leading,
            trailingWidgets: trailing,
            cellBuilder: cellBuilder,
          ),
        ),
      );

      final listGroup = tester.widget<ListSelectionGroup<_TestModel>>(
        find.byType(ListSelectionGroup<_TestModel>),
      );

      expect(listGroup.uiModels, testModels);
      expect(listGroup.layoutConfig, layoutConfig);
      expect(listGroup.initialSelectionIndices, initialIndices);
      expect(listGroup.maxSelectionCount, maxSelectionCount);
      expect(listGroup.onSelectionOverflow, onSelectionOverflow);
      expect(listGroup.onSelectionChanged, onSelectionChanged);
      expect(listGroup.leadingWidgets, leading);
      expect(listGroup.trailingWidgets, trailing);
      expect(listGroup.cellBuilder, cellBuilder);
    },
  );

  testWidgets(
    'InfinitySelectionGroup passes parameters correctly to GridSelectionGroup',
    (tester) async {
      const layoutConfig = GridLayoutConfig();
      final leading = [const SizedBox(key: Key('leading'))];
      final trailing = [const SizedBox(key: Key('trailing'))];
      const initialIndices = [1];
      const maxSelectionCount = 2;
      void onSelectionChanged(_) {}
      void onSelectionOverflow() {}
      Widget cellBuilder(model, {required selected}) => const SizedBox();

      await tester.pumpWidget(
        wrap(
          InfinitySelectionGroup<_TestModel>(
            uiModels: testModels,
            layoutConfig: layoutConfig,
            initialSelectionIndices: initialIndices,
            maxSelectionCount: maxSelectionCount,
            onSelectionOverflow: onSelectionOverflow,
            onSelectionChanged: onSelectionChanged,
            leadingWidgets: leading,
            trailingWidgets: trailing,
            cellBuilder: cellBuilder,
          ),
        ),
      );

      final gridGroup = tester.widget<GridSelectionGroup<_TestModel>>(
        find.byType(GridSelectionGroup<_TestModel>),
      );

      expect(gridGroup.uiModels, testModels);
      expect(gridGroup.layoutConfig, layoutConfig);
      expect(gridGroup.initialSelectionIndices, initialIndices);
      expect(gridGroup.maxSelectionCount, maxSelectionCount);
      expect(gridGroup.onSelectionOverflow, onSelectionOverflow);
      expect(gridGroup.onSelectionChanged, onSelectionChanged);
      expect(gridGroup.leadingWidgets, leading);
      expect(gridGroup.trailingWidgets, trailing);
      expect(gridGroup.cellBuilder, cellBuilder);
    },
  );

  testWidgets(
    'InfinitySelectionGroup passes parameters correctly to WrapSelectionGroup',
    (tester) async {
      const layoutConfig = WrapLayoutConfig();
      final leading = [const SizedBox(key: Key('leading'))];
      final trailing = [const SizedBox(key: Key('trailing'))];
      const initialIndices = [1];
      const maxSelectionCount = 2;
      void onSelectionChanged(_) {}
      void onSelectionOverflow() {}
      Widget cellBuilder(model, {required selected}) => const SizedBox();

      await tester.pumpWidget(
        wrap(
          InfinitySelectionGroup<_TestModel>(
            uiModels: testModels,
            layoutConfig: layoutConfig,
            initialSelectionIndices: initialIndices,
            maxSelectionCount: maxSelectionCount,
            onSelectionOverflow: onSelectionOverflow,
            onSelectionChanged: onSelectionChanged,
            leadingWidgets: leading,
            trailingWidgets: trailing,
            cellBuilder: cellBuilder,
          ),
        ),
      );

      final wrapGroup = tester.widget<WrapSelectionGroup<_TestModel>>(
        find.byType(WrapSelectionGroup<_TestModel>),
      );

      expect(wrapGroup.uiModels, testModels);
      expect(wrapGroup.layoutConfig, layoutConfig);
      expect(wrapGroup.initialSelectionIndices, initialIndices);
      expect(wrapGroup.maxSelectionCount, maxSelectionCount);
      expect(wrapGroup.onSelectionOverflow, onSelectionOverflow);
      expect(wrapGroup.onSelectionChanged, onSelectionChanged);
      expect(wrapGroup.leadingWidgets, leading);
      expect(wrapGroup.trailingWidgets, trailing);
      expect(wrapGroup.cellBuilder, cellBuilder);
    },
  );
}
