# snacker

A top-level snack bar presenter.

## Installation

#### From pub.dev

Add this to your `pubspec.yaml`

```yaml
dependencies:
  snacker: ^1.0.0
```

#### Or, From Git repo

```yaml
dependencies:
  snacker:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: snacker
      ref: snacker-1.0.0
```

## Getting Started

### 1. Create a GlobalKey

To use the Snacker, you need to create a `GlobalKey<ScaffoldMessengerState>` instance and use that:

1. As `scaffoldMessengerKey` while constructing the app root (e.g., `MaterialApp`)
2. To construct the `ScaffoldMessengerSnacker` instance, a concrete Snacker implementation based on `ScaffoldMessenger`.

```dart
// Create the global key
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

// Create the snacker with the same key instance.
final snacker = ScaffoldMessengerSnacker(scaffoldMessengerKey);

// Attach to app root
void main() {
  runApp(
    MaterialApp(
      // Use the same key instance here.
      scaffoldMessengerKey: scaffoldMessengerKey,
      home: HomePage(snacker: snacker),
    ),
  );
}
```

### 2. Show a snack

Call `showTextSnack` with a `SnackData` whenever needed. Use `SnackData.info`, `SnackData.success`, `SnackData.warning`, or `SnackData.error` to pick the style.

```dart
// ...

void showSnack() {
  snacker.showTextSnack(SnackData.error(message: 'Something went wrong'));
}
```

## Key Components

| Component                  | Description                                                                                                                       |
|----------------------------|-----------------------------------------------------------------------------------------------------------------------------------|
| `Snacker`                  | Abstract presenter. Responsible for *how* a snack is shown. Subclass it to change the source of context.                          |
| `ScaffoldMessengerSnacker` | Ready-to-use `Snacker` that shows snacks via a `ScaffoldMessenger`.                                                               |
| `SnackBarBuilder`          | Decides the snack's *appearance*. Override its hooks to customize the look.                                                       |
| `DefaultSnackBarBuilder`   | The default `SnackBarBuilder` with the standard styling.                                                                          |
| `SnackData`                | Holds the snack's content and type. Create with `SnackData.info`, `SnackData.success`, `SnackData.warning`, or `SnackData.error`. |
| `SnackType`                | Enum of snack styles: `INFO`, `SUCCESS`, `WARNING`, `ERROR`.                                                                      |

> Notes:
> - To customize the looks, extend `SnackBarBuilder` and override its hooks (e.g., `buildSnackContent`, `getSnackBarBackgroundColor`), then pass it to `ScaffoldMessengerSnacker`.
> - To create a new implementation, implement `Snacker` and provide your own context.

## Example

See the [example](example/example.dart) for a complete demonstration.
