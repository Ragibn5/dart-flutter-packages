# infinity_radio_group

A fully customizable radio group widget for Flutter.

## Installation

#### From pub.dev

Add this to your `pubspec.yaml`

```yaml
dependencies:
  infinity_radio_group: ^2.0.1
```

#### Or, From Git repo

```yaml
dependencies:
  infinity_radio_group:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: infinity_radio_group
      ref: infinity_radio_group-2.0.1
```

## ✨ Features

- **🗂️ Three layouts** — render options as a list, a grid, or flowing chips, all through one widget.
- **🎨 UI-agnostic** — you build each option's look yourself, so every cell is exactly how you want it.
- **🔒 Non-selectable items** — mark any option as excluded, and it is skipped from the selection automatically.
- **📌 Programmatic selection** — start with an option already selected.
- **➕ Leading/trailing widgets** — prepend or append custom widgets (headers, dividers, buttons) alongside the options.
- **🔀 Wide compatibility** — works with Flutter 3.10.6+.

## 📸 Preview

<table>
  <tr>
    <td><img src="https://raw.githubusercontent.com/Ragibn5/dart-flutter-packages/main/infinity_radio_group/assets/list_preview.jpeg" alt="List layout"></td>
    <td><img src="https://raw.githubusercontent.com/Ragibn5/dart-flutter-packages/main/infinity_radio_group/assets/grid_preview.jpeg" alt="Grid layout"></td>
    <td><img src="https://raw.githubusercontent.com/Ragibn5/dart-flutter-packages/main/infinity_radio_group/assets/wrap_preview.jpeg" alt="Wrap layout"></td>
  </tr>
</table>

## 🚀 Get Started

### 1. Define your option model

Extend `RadioItemUiModel` and carry any data you need.

```
import 'package:infinity_radio_group/infinity_radio_group.dart';

class PlanOption extends RadioItemUiModel {
  final String title;
  final IconData icon;

  const PlanOption({
    required this.title,
    required this.icon,
    super.shouldBeSelected = true,
  });
}
```

> **Note:** Set `shouldBeSelected` to `false` to exclude an option from the selection.

### 2. Pick a layout config

The package supports three layout styles. Use the one that best fits your needs. For example, if you want a grid style radio group, use `GridLayoutConfig`.

```
final listLayout = ListLayoutConfig(spacing: 8);

final gridLayout = GridLayoutConfig(
  crossAxisItemCount: 2,
  horizontalSpacing: 8,
  verticalSpacing: 8,
);

final wrapLayout = WrapLayoutConfig(spacing: 8, runSpacing: 8);
```

See the [API](#-api) section for the full parameter list of each config.

### 3. Render the radio group

Use the [InfinityRadioGroup] widget to render your options using the supplied layout.

```
InfinityRadioGroup<PlanOption>(
  uiModels: plans,
  layoutConfig: listLayout,
  initialSelectionIndex: 0,
  onSelectionChanged: (plan) {
    print('Selected: ${plan.title}');
  },
  cellBuilder: (model, {required selected}) => ListTile(
    leading: Icon(model.icon),
    title: Text(model.title),
    trailing: Icon(
      selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
    ),
  ),
)
```

That's it — the selected cell is highlighted through the `selected` flag your builder receives, and `onSelectionChanged` fires whenever the user picks a different option.

## 📦 API

All exported components from `package:infinity_radio_group/infinity_radio_group.dart`:

| Component               | Description                                                                                           |
|-------------------------|-------------------------------------------------------------------------------------------------------|
| `InfinityRadioGroup<T>` | The main widget. Dispatches to list, grid, or wrap based on the supplied `layoutConfig`.              |
| `RadioItemUiModel`      | Base class for your options — carries `shouldBeSelected` so you can exclude items from the selection. |
| `ListLayoutConfig`      | Layout options for a vertical or horizontal list — spacing, padding, scrolling.                       |
| `GridLayoutConfig`      | Layout options for a grid — `crossAxisItemCount`, axis, vertical/horizontal spacing.                  |
| `WrapLayoutConfig`      | Layout options for a wrap (chip-like) layout — spacing and run spacing.                               |
| `ListRadioGroup<T>`     | The list implementation directly, if you want to skip the dispatch.                                   |
| `GridRadioGroup<T>`     | The grid implementation directly.                                                                     |
| `WrapRadioGroup<T>`     | The wrap implementation directly.                                                                     |

## 🧪 Example

See [`example.dart`](example/example.dart) for a complete runnable example, or [`demo/`](demo) for a standalone Flutter project.

---