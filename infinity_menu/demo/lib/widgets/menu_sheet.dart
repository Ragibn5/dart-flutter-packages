import 'package:flutter/material.dart';
import 'package:infinity_menu/infinity_menu.dart';

import 'package:example/widgets/menu_header.dart';
import 'package:example/widgets/menu_item.dart';

class MenuSheet extends StatelessWidget {
  const MenuSheet({
    super.key,
    required this.title,
    required this.menuData,
    required this.parent,
    required this.onSubmenuRequest,
  });

  final String title;
  final MenuData<String> menuData;
  final MenuItemData<String>? parent;
  final void Function(
    BuildContext context,
    MenuData<String> submenu,
    MenuItemData<String> parent,
  ) onSubmenuRequest;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          InfinityMenu<String>(
            parent: parent,
            menuData: menuData,
            menuHeaderBuilder: (_, p) => MenuHeader(
              parentItemData: p,
              rootTitle: title,
            ),
            menuItemBuilder: (index, _, item) => MenuItemWidget(
              item: item,
              index: index,
            ),
            onSubmenuRequest: (ctx, submenu, parentItem) =>
                onSubmenuRequest(ctx, submenu, parentItem),
          ),
        ],
      ),
    );
  }
}
