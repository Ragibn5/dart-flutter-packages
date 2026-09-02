import 'package:dev_tools/dev_tools.dart';

Future<void> main() async {
  const flutterCommandFinder = FvmAwareFlutterCommandFinder();
  const dartCommandFinder = FvmAwareDartCommandFinder();
  print('Flutter command: ${await flutterCommandFinder()}');
  print('Dart command: ${await dartCommandFinder()}');

  final root = await const FindProjectRoot()();
  print('Project root: $root');
  print('Dart package: ${await const GetCurrentDartPackage()(root)}');

  final branch = await const GetCurrentBranch()();
  print('Current branch: $branch');
}
