# ∞ infinity_menu

An infinitely customizable Menu for flutter apps with support for nested menu and much more.

## Installation

#### From pub.dev

Add this to your `pubspec.yaml`

```yaml
dependencies:
  infinity_menu: ^2.0.1
```

#### Or, From Git repo

```yaml
dependencies:
  infinity_menu:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: infinity_menu
      ref: infinity_menu-2.0.1
```

## ✨ Features

- **♾️ Infinite nesting** — nest submenus to any depth.
- **🎨 UI-agnostic** — you control how everything looks via builder callbacks.
- **📦 Type-safe** — carry any data type through your menu and get it back as a strongly typed value on selection.
- **🔀 Wide compatibility** — works with Flutter 3.10.6+.

## 📸 Preview

<table>
  <tr>
    <td><img src="https://raw.githubusercontent.com/Ragibn5/dart-flutter-packages/main/infinity_menu/assets/screenshots/0.png" alt="Home screen"></td>
    <td><img src="https://raw.githubusercontent.com/Ragibn5/dart-flutter-packages/main/infinity_menu/assets/screenshots/3.png" alt="Menu selected"></td>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/Ragibn5/dart-flutter-packages/main/infinity_menu/assets/screenshots/1.1.png" alt="Deep nesting - level 1"></td>
    <td><img src="https://raw.githubusercontent.com/Ragibn5/dart-flutter-packages/main/infinity_menu/assets/screenshots/1.2.png" alt="Deep nesting - level 2"></td>
    <td><img src="https://raw.githubusercontent.com/Ragibn5/dart-flutter-packages/main/infinity_menu/assets/screenshots/1.3.png" alt="Deep nesting - level 3"></td>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/Ragibn5/dart-flutter-packages/main/infinity_menu/assets/screenshots/2.1.png" alt="Settings menu"></td>
    <td><img src="https://raw.githubusercontent.com/Ragibn5/dart-flutter-packages/main/infinity_menu/assets/screenshots/2.2.png" alt="Settings submenu"></td>
  </tr>
</table>

## 🚀 Get Started

### 1. Define your menu data

Build your menu tree with `MenuData` and `MenuItemData`. Nest as deep as you want — just set `subMenuData`.

```
import 'package:infinity_menu/infinity_menu.dart';

final menuData = MenuData<String>(
  menuItems: [
    MenuItemData<String>(
      data: 'theme',
      itemTitle: 'Theme',
      subMenuData: MenuData<String>(
        menuItems: [
          MenuItemData(data: 'light', itemTitle: 'Light', onItemAction: _onSelect),
          MenuItemData(data: 'dark', itemTitle: 'Dark', onItemAction: _onSelect),
        ],
      ),
    ),
    MenuItemData(data: 'settings', itemTitle: 'Settings', onItemAction: _onSelect),
  ],
);
```

### 2. Present the menu

Drop an `InfinityMenu` into any widget — bottom sheet, popup, dialog, wherever. You control how each item looks via `menuItemBuilder`.

```
showModalBottomSheet(
  context: context,
  builder: (_) => InfinityMenu<String>(
    menuData: menuData,
    menuItemBuilder: (index, size, item) => ListTile(
      title: Text(item.itemTitle),
      trailing: item.subMenuData != null ? Icon(Icons.chevron_right) : null,
    ),
    separatorBuilder: (_, __, ___) => Divider(height: 1),
    menuHeaderBuilder: (_, parent) => Padding(
      padding: EdgeInsets.all(8),
      child: Text(parent?.itemTitle ?? 'Menu', style: TextStyle(fontWeight: FontWeight.bold)),
    ),
    onSubmenuRequest: (ctx, submenu, parent) => _openMenu(ctx, submenu),
  ),
);
```

### 3. Recursively open submenus

When a user taps an item with a submenu, `onSubmenuRequest` fires. Just call your own function again — the recursion handles the rest.

```
void _openMenu(BuildContext context, MenuData<String> submenu) {
  showModalBottomSheet(
    context: context,
    builder: (_) => InfinityMenu<String>(
      menuData: submenu,
      menuItemBuilder: (index, size, item) => ListTile(title: Text(item.itemTitle)),
      onSubmenuRequest: (ctx, sub, parent) => _openMenu(ctx, sub),
    ),
  );
}
```

## 📦 API

All exported components from `package:infinity_menu/infinity_menu.dart`:

| Component               | Description                                                                                                    |
|-------------------------|----------------------------------------------------------------------------------------------------------------|
| `InfinityMenu<D>`       | The main widget. Renders a `MenuData<D>` as a list, handling tap feedback, item actions, and submenu dispatch. |
| `MenuData<D>`           | Holds a list of `MenuItemData<D>` items and a `MenuLayoutConfig`.                                              |
| `MenuItemData<D>`       | A single menu item — title, optional icon, optional payload `D`, optional submenu, optional tap callback.      |
| `IconFromIconData`      | Icon variant — wraps a Flutter `IconData`.                                                                     |
| `IconFromPath`          | Icon variant — wraps an asset path string.                                                                     |
| `MenuLayoutConfig`      | Layout options — shrink wrap, padding, scroll physics, selection feedback.                                     |
| `OpacityFeedbackConfig` | Tap feedback — briefly dims the tapped item.                                                                   |
| `OverlayFeedbackConfig` | Tap feedback — briefly shows a colored overlay on the tapped item.                                             |

## 🧪 Example

See [`example.dart`](example/example.dart) for a complete runnable example, or [`demo/`](demo) for a standalone Flutter project.

---