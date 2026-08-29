# preference_store

A key-value data store.

## Installation

#### From pub.dev

Add this to your `pubspec.yaml`

```yaml
dependencies:
  preference_store: ^1.0.0
```

#### Or, From Git repo

```yaml
dependencies:
  preference_store:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: preference_store
      ref: preference_store-1.0.0
```

## 💾 Usage

### 🛠️ Creating a store

Create a `PreferenceStore` through the factory.

```dart
void test() async {
  final PreferenceStore store = const PreferenceStoreFactory().create();

  await store.setString('name', 'Alice');
  final name = await store.getString('name');
}
```

### 👁️ Read-only and write-only access ✍️

The `PreferenceStore` implements both `PreferenceReader` and `PreferenceWriter` interfaces, so consumers can depend on the narrowest capability they actually need.

```dart
Future<String> greet(PreferenceReader reader) async {
  return 'Hello, ${await reader.getString('name')}!';
}

Future<void> saveName(PreferenceWriter writer) async {
  await writer.setString('name', 'Alice');
}
```

Because a `PreferenceStore` implements both interfaces, the same instance can be passed to either:

```dart
final PreferenceStore store = const PreferenceStoreFactory().create();

saveName(store);
greet(store);
```

This keeps read-only consumers from accidentally writing (and vice versa) while allowing the interface segregation to evolve independently of the backing implementation.

## 🧪 Example

See the [example](example/example.dart) for a complete demonstration.
