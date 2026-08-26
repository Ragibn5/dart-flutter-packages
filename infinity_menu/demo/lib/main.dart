import 'package:flutter/material.dart';
import 'package:infinity_menu/infinity_menu.dart';

import 'package:example/widgets/demo_header.dart';
import 'package:example/widgets/menu_demo_option.dart';
import 'package:example/widgets/menu_option_tile.dart';
import 'package:example/widgets/menu_sheet.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Infinity Menu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF4F46E5),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _lastSelection;
  MenuDemoOption? _activeDemo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            DemoHeader(lastSelection: _lastSelection, activeDemo: _activeDemo),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                children: [
                  for (final demo in menuDemoOptions)
                    MenuOptionTile(
                      model: demo,
                      onTap: () => _openMenu(
                        context,
                        demo.title,
                        demo.buildMenu(_onItemAction),
                        null,
                        demo,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openMenu(
    BuildContext context,
    String title,
    MenuData<String> menuData,
    MenuItemData<String>? parent, [
    MenuDemoOption? demo,
  ]) {
    if (demo != null) {
      setState(() => _activeDemo = demo);
    }

    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => MenuSheet(
        title: title,
        menuData: menuData,
        parent: parent,
        onSubmenuRequest: (ctx, submenu, parentItem) =>
            _openMenu(ctx, parentItem.itemTitle, submenu, parentItem),
      ),
    );
  }

  void _onItemAction(String? data) {
    setState(() => _lastSelection = data);
  }
}
