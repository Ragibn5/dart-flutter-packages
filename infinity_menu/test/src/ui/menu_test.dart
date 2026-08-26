// ignore_for_file: avoid_redundant_argument_values, lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinity_menu/src/configs/menu_layout_config.dart';
import 'package:infinity_menu/src/models/menu_data.dart';
import 'package:infinity_menu/src/models/menu_item_data.dart';
import 'package:infinity_menu/src/ui/feedback/click_feedback_container.dart';
import 'package:infinity_menu/src/ui/infinity_menu.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  MenuItemData<String> buildItem({
    String data = 'data',
    String title = 'Item',
    void Function(String? data)? onItemAction,
    MenuData<String>? subMenuData,
  }) {
    return MenuItemData<String>(
      data: data,
      itemTitle: title,
      onItemAction: onItemAction,
      subMenuData: subMenuData,
    );
  }

  MenuData<String> buildMenuData({
    List<MenuItemData<String>>? items,
    MenuLayoutConfig config = const MenuLayoutConfig(),
  }) {
    return MenuData<String>(
      menuLayoutConfig: config,
      menuItems: items ?? [buildItem()],
    );
  }

  Widget textItemBuilder(int index, int size, MenuItemData<String> item) =>
      Text(item.itemTitle);

  Widget buildItemWidget() =>
      Container(width: 100, height: 50, color: Colors.blue);

  Future<void> tapFirstItem(WidgetTester tester) async {
    await tester.tap(find.byType(ClickFeedbackContainer).first);
    await tester.pump();
  }

  group('build', () {
    testWidgets('ListView receives correct item count', (tester) async {
      await tester.pumpWidget(
        wrap(
          InfinityMenu<String>(
            menuData: buildMenuData(
              items: [buildItem(), buildItem(), buildItem()],
            ),
            menuItemBuilder: textItemBuilder,
          ),
        ),
      );

      final listView = tester.widget<ListView>(find.byType(ListView));
      // +1 because index 0 is reserved for the header slot
      expect(listView.semanticChildCount, 4);
    });

    testWidgets(
      'ListView receives correct layout config values',
      (tester) async {
        const padding = EdgeInsets.all(16);
        const physics = ClampingScrollPhysics();

        await tester.pumpWidget(
          wrap(
            InfinityMenu<String>(
              menuData: buildMenuData(
                config: const MenuLayoutConfig(
                  shrinkWrap: false,
                  padding: padding,
                  scrollPhysics: physics,
                ),
              ),
              menuItemBuilder: textItemBuilder,
            ),
          ),
        );

        final listView = tester.widget<ListView>(find.byType(ListView));
        expect(listView.shrinkWrap, false);
        expect(listView.padding, padding);
        expect(listView.physics, isA<ClampingScrollPhysics>());
      },
    );
  });

  group('menuItemBuilder', () {
    testWidgets(
      'Only header is built when no menu items were provided, but header is provided',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            InfinityMenu<String>(
              menuData: buildMenuData(items: []),
              menuItemBuilder: (index, size, item) => const Text('Item'),
              menuHeaderBuilder: (context, _) => const Text('Header'),
            ),
          ),
        );

        expect(find.text('Header'), findsOneWidget);
        expect(find.text('Item'), findsNothing);
      },
    );

    testWidgets('Renders menu items using menuItemBuilder', (tester) async {
      await tester.pumpWidget(
        wrap(
          InfinityMenu<String>(
            menuData: buildMenuData(items: [
              buildItem(title: 'Item 1'),
              buildItem(title: 'Item 2'),
              buildItem(title: 'Item 3'),
            ]),
            menuItemBuilder: textItemBuilder,
          ),
        ),
      );

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
    });

    testWidgets(
      'Passes correct index, hostMenuSize and itemData to menuItemBuilder',
      (tester) async {
        final items = [buildItem(title: 'Item 1'), buildItem(title: 'Item 2')];
        final captured = <(int, int, MenuItemData<String>)>[];

        await tester.pumpWidget(
          wrap(
            InfinityMenu<String>(
              menuData: buildMenuData(items: items),
              menuItemBuilder: (index, hostMenuSize, itemData) {
                captured.add((index, hostMenuSize, itemData));
                return Text(itemData.itemTitle);
              },
            ),
          ),
        );

        expect(captured[0], (0, 2, items[0]));
        expect(captured[1], (1, 2, items[1]));
      },
    );

    testWidgets('Renders no items when menuItems is empty', (tester) async {
      await tester.pumpWidget(
        wrap(
          InfinityMenu<String>(
            menuData: buildMenuData(items: []),
            menuItemBuilder: (index, hostMenuSize, itemData) {
              return const Text('Item');
            },
          ),
        ),
      );

      expect(find.text('Item'), findsNothing);
    });

    testWidgets('Wraps each item with ClickFeedbackContainer', (tester) async {
      await tester.pumpWidget(
        wrap(
          InfinityMenu<String>(
            menuData: buildMenuData(
              items: [buildItem(), buildItem(), buildItem()],
            ),
            menuItemBuilder: textItemBuilder,
          ),
        ),
      );

      expect(find.byType(ClickFeedbackContainer), findsNWidgets(3));
    });
  });

  group('menuHeaderBuilder', () {
    testWidgets(
      'Renders header when menuHeaderBuilder is provided',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            InfinityMenu<String>(
              menuData: buildMenuData(),
              menuItemBuilder: textItemBuilder,
              menuHeaderBuilder: (context, _) => const Text('Header'),
            ),
          ),
        );

        expect(find.text('Header'), findsOneWidget);
      },
    );

    testWidgets(
      'Does not render header when menuHeaderBuilder is omitted',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            InfinityMenu<String>(
              menuData: buildMenuData(),
              menuItemBuilder: textItemBuilder,
            ),
          ),
        );

        expect(find.text('Header'), findsNothing);
      },
    );

    testWidgets(
      'Passes null parent to header for root menu',
      (tester) async {
        MenuItemData<String>? receivedRootItem = MenuItemData(
          data: 'placeholder',
          itemTitle: 'placeholder',
        );

        await tester.pumpWidget(
          wrap(
            InfinityMenu<String>(
              menuData: buildMenuData(),
              menuItemBuilder: textItemBuilder,
              menuHeaderBuilder: (context, parent) {
                receivedRootItem = parent;
                return const SizedBox();
              },
            ),
          ),
        );

        expect(receivedRootItem, isNull);
      },
    );

    testWidgets('Passes parentItem to header for submenu menu', (tester) async {
      final parentItem = buildItem(title: 'Parent');
      MenuItemData<String>? receivedParentItem;

      await tester.pumpWidget(
        wrap(
          InfinityMenu<String>(
            parent: parentItem,
            menuData: buildMenuData(),
            menuItemBuilder: textItemBuilder,
            menuHeaderBuilder: (context, parent) {
              receivedParentItem = parent;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(receivedParentItem, same(parentItem));
    });
  });

  group('separatorBuilder', () {
    testWidgets('Does not render separator between header and first item',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          InfinityMenu<String>(
            menuData: buildMenuData(items: [buildItem()]),
            menuItemBuilder: (index, size, item) => const Text('Item'),
            menuHeaderBuilder: (context, _) => const Text('Header'),
            separatorBuilder: (_, __, ___) => const Text('Separator'),
          ),
        ),
      );

      expect(find.text('Item'), findsOneWidget);
      expect(find.text('Header'), findsOneWidget);
      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.text('Separator'), findsNothing);
    });

    testWidgets(
        'Renders separator between items when separatorBuilder is provided',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          InfinityMenu<String>(
            menuData: buildMenuData(
              items: [buildItem(), buildItem(), buildItem()],
            ),
            menuItemBuilder: textItemBuilder,
            separatorBuilder: (index, size, item) => const Text('Separator'),
          ),
        ),
      );

      // 3 items → 2 separators between them (first slot is header, skipped)
      expect(find.text('Separator'), findsNWidgets(2));
    });

    testWidgets('Does not render separator when separatorBuilder is omitted',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          InfinityMenu<String>(
            menuData: buildMenuData(items: [buildItem(), buildItem()]),
            menuItemBuilder: textItemBuilder,
          ),
        ),
      );

      expect(find.text('Separator'), findsNothing);
    });

    testWidgets('Does not render separator before first item', (tester) async {
      await tester.pumpWidget(
        wrap(
          InfinityMenu<String>(
            menuData: buildMenuData(items: [buildItem(), buildItem()]),
            menuItemBuilder: (index, size, item) => Text('Item $index'),
            separatorBuilder: (index, size, item) => const Text('Separator'),
          ),
        ),
      );

      // 2 items → only 1 separator between them, not before Item 0
      expect(find.text('Separator'), findsOneWidget);
    });

    testWidgets(
        'Passes correct index, hostMenuSize and itemData to separatorBuilder',
        (tester) async {
      final items = [
        buildItem(title: 'Item 1'),
        buildItem(title: 'Item 2'),
        buildItem(title: 'Item 3'),
      ];
      final captured = <(int, int, MenuItemData<String>)>[];

      await tester.pumpWidget(
        wrap(
          InfinityMenu<String>(
            menuData: buildMenuData(items: items),
            menuItemBuilder: textItemBuilder,
            separatorBuilder: (index, hostMenuSize, itemData) {
              captured.add((index, hostMenuSize, itemData));
              return Text(itemData.itemTitle);
            },
          ),
        ),
      );

      expect(captured[0], (0, 3, items[0]));
      expect(captured[1], (1, 3, items[1]));
    });

    testWidgets('Renders no separators when menuItems is empty',
        (tester) async {
      await tester.pumpWidget(
        wrap(
          InfinityMenu<String>(
            menuData: buildMenuData(items: []),
            menuItemBuilder: textItemBuilder,
            separatorBuilder: (index, size, item) => const Text('Separator'),
          ),
        ),
      );

      expect(find.text('Separator'), findsNothing);
    });
  });

  group('onItemAction', () {
    testWidgets('Calls onItemAction when item is tapped', (tester) async {
      var actionCalled = false;

      await tester.pumpWidget(
        wrap(
          InfinityMenu<String>(
            menuData: buildMenuData(
              items: [buildItem(onItemAction: (_) => actionCalled = true)],
            ),
            menuItemBuilder: (index, size, item) => buildItemWidget(),
          ),
        ),
      );

      await tapFirstItem(tester);

      expect(actionCalled, isTrue);
    });

    testWidgets('Does not throw when onItemAction is null', (tester) async {
      await tester.pumpWidget(
        wrap(
          InfinityMenu<String>(
            menuData: buildMenuData(items: [buildItem(onItemAction: null)]),
            menuItemBuilder: (index, size, item) => buildItemWidget(),
            onPop: (_) {},
          ),
        ),
      );

      expect(
        () async => tester.tap(find.byType(ClickFeedbackContainer).first),
        returnsNormally,
      );
    });

    testWidgets(
      'Calls both onItemAction and onSubmenuRequest when item has both',
      (tester) async {
        var actionCalled = false;
        MenuItemData<String>? receivedParentItem;
        MenuData<String>? receivedSubmenu;
        final item = buildItem(
          onItemAction: (_) => actionCalled = true,
          subMenuData: buildMenuData(items: [buildItem(title: 'Sub Item')]),
        );

        await tester.pumpWidget(
          wrap(
            InfinityMenu<String>(
              menuData: buildMenuData(
                items: [item],
              ),
              menuItemBuilder: (index, size, item) => buildItemWidget(),
              onSubmenuRequest: (context, submenu, parent) {
                receivedParentItem = parent;
                receivedSubmenu = submenu;
              },
              onPop: (_) {},
            ),
          ),
        );

        await tapFirstItem(tester);

        expect(actionCalled, isTrue);
        expect(receivedParentItem, same(item));
        expect(receivedSubmenu, same(item.subMenuData));
      },
    );
  });

  group('onSubmenuRequest', () {
    testWidgets(
      'Calls onSubmenuRequest when item with submenu is tapped',
      (tester) async {
        MenuItemData<String>? receivedParentItem;
        MenuData<String>? receivedSubmenu;
        final item = buildItem(
          subMenuData: buildMenuData(items: [buildItem(title: 'Sub Item')]),
        );

        await tester.pumpWidget(
          wrap(
            InfinityMenu<String>(
              menuData: buildMenuData(
                items: [item],
              ),
              menuItemBuilder: (index, size, item) => buildItemWidget(),
              onSubmenuRequest: (context, submenu, parent) {
                receivedParentItem = parent;
                receivedSubmenu = submenu;
              },
              onPop: (_) {},
            ),
          ),
        );

        await tapFirstItem(tester);

        expect(receivedParentItem, same(item));
        expect(receivedSubmenu, same(item.subMenuData));
      },
    );

    testWidgets('Does not call onSubmenuRequest when submenu is empty',
        (tester) async {
      var submenuRequestCalled = false;

      await tester.pumpWidget(
        wrap(
          InfinityMenu<String>(
            menuData: buildMenuData(
              items: [buildItem(subMenuData: buildMenuData(items: []))],
            ),
            menuItemBuilder: (index, size, item) => buildItemWidget(),
            onSubmenuRequest: (context, parent, submenu) {
              submenuRequestCalled = true;
            },
            onPop: (_) {},
          ),
        ),
      );

      await tapFirstItem(tester);

      expect(submenuRequestCalled, isFalse);
    });

    testWidgets(
      'Does not throw when onSubmenuRequest is null and item has submenu',
      (tester) async {
        final submenuData =
            buildMenuData(items: [buildItem(title: 'Sub Item')]);

        await tester.pumpWidget(
          wrap(
            InfinityMenu<String>(
              menuData: buildMenuData(
                items: [buildItem(subMenuData: submenuData)],
              ),
              menuItemBuilder: (index, size, item) => buildItemWidget(),
              onPop: (_) {},
            ),
          ),
        );

        expect(
          () async => tester.tap(find.byType(ClickFeedbackContainer).first),
          returnsNormally,
        );
      },
    );
  });

  group('onPop', () {
    testWidgets('Calls custom onPop when item is tapped', (tester) async {
      var popCalled = false;

      await tester.pumpWidget(
        wrap(
          InfinityMenu<String>(
            menuData: buildMenuData(),
            menuItemBuilder: (index, size, item) => buildItemWidget(),
            onPop: (context) => popCalled = true,
          ),
        ),
      );

      await tapFirstItem(tester);

      expect(popCalled, isTrue);
    });

    testWidgets(
      'Calls Navigator.pop when onPop is not provided',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<dynamic>(
                      builder: (_) => Scaffold(
                        body: InfinityMenu<String>(
                          menuData: buildMenuData(),
                          menuItemBuilder: (index, size, item) =>
                              buildItemWidget(),
                        ),
                      ),
                    ),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.byType(InfinityMenu<String>), findsOneWidget);

        await tester.tap(find.byType(ClickFeedbackContainer).first);
        await tester.pumpAndSettle();

        expect(find.byType(InfinityMenu<String>), findsNothing);
      },
    );
  });
}
