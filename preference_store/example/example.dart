import 'package:preference_store/preference_store.dart';

Future<void> saveName(PreferenceWriter writer) async {
  await writer.setString('name', 'Alice');
}

Future<String> greet(PreferenceReader reader) async {
  return 'Hello, ${await reader.getString('name')}!';
}

Future<void> updateName(PreferenceStore store) async {
  final current = await store.getString('name');
  await store.setString('name', '$current Jr.');
}

void main() async {
  final store = const PreferenceStoreFactory().create();

  // The same store instance implements both interfaces, so it can be
  // used anywhere a PreferenceReader or PreferenceWriter is expected.
  await saveName(store);
  final greeting = await greet(store);

  // Or, it can be used as the full store, which reads and writes.
  await updateName(store);
  final updated = await greet(store);

  print('$greeting -> $updated');

  await store.remove('name');
}
