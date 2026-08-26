// ignore_for_file: unnecessary_lambdas

import 'package:flutter/material.dart';
import 'package:infinity_menu/infinity_menu.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Infinity Menu',
      home: Scaffold(
        appBar: AppBar(title: const Text('Infinity Menu')),
        body: Center(child: Builder(builder: (context) {
          return FilledButton(
            onPressed: () => _openMenu(context, _menuData, null),
            child: const Text('Open Menu'),
          );
        })),
      ),
    );
  }
}

final _menuData = MenuData<String>(
  menuItems: [
    MenuItemData<String>(
      data: 'theme',
      itemTitle: 'Theme',
      itemIcon: IconFromIconData(Icons.palette),
      subMenuData: MenuData<String>(
        menuItems: [
          MenuItemData(data: 'light', itemTitle: 'Light'),
          MenuItemData(data: 'dark', itemTitle: 'Dark'),
        ],
      ),
    ),
    MenuItemData<String>(
      data: 'settings',
      itemTitle: 'Settings',
      itemIcon: IconFromIconData(Icons.settings),
    ),
    MenuItemData<String>(
      data: 'about',
      itemTitle: 'About',
    ),
  ],
);

void _openMenu(
  BuildContext context,
  MenuData<String> menuData,
  MenuItemData<String>? parent,
) {
  showModalBottomSheet<void>(
    context: context,
    builder: (_) => SafeArea(
      child: InfinityMenu<String>(
        parent: parent,
        menuData: menuData,
        menuItemBuilder: (_, __, item) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              if (item.itemIcon case IconFromIconData(:final iconData))
                Icon(iconData),
              const SizedBox(width: 12),
              Expanded(child: Text(item.itemTitle)),
              if (item.subMenuData != null)
                const Icon(Icons.chevron_right, size: 20),
            ],
          ),
        ),
        menuHeaderBuilder: (_, parent) => Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            parent?.itemTitle ?? 'Menu',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        separatorBuilder: (_, __, ___) => const Divider(height: 1),
        onSubmenuRequest: (ctx, submenu, parent) =>
            _openMenu(ctx, submenu, parent),
      ),
    ),
  );
}
