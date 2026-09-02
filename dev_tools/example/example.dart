// ignore_for_file: avoid_print

import 'package:dev_tools/dev_tools.dart';

Future<void> main() async {
  const flutterCommandFinder = FlutterCommandFinder();
  const dartCommandFinder = DartCommandFinder();
  print('Flutter command: ${await flutterCommandFinder()}');
  print('Dart command: ${await dartCommandFinder()}');

  const projectUtils = ProjectUtils();
  final root = await projectUtils.findProjectRoot();
  print('Project root: $root');
  print('Dart package: ${await projectUtils.getCurrentDartPackage(root)}');

  const gitUtils = GitUtils();
  final branch = await gitUtils.currentBranch();
  print('Current branch: $branch');
}
