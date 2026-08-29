import 'package:preference_store/preference_store.dart';

void main() async {
  const factory = PreferenceStoreFactory();
  final store = factory.create();

  await store.setString('name', 'Alice');
  final name = await store.getString('name');
  print('Hello, $name!');

  await store.remove('name');
}
