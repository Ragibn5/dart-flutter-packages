import 'package:dev_tools/src/use_cases/dart_flutter/find_fvm_aware_dart_command.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_fvm_aware_flutter_command.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_project_root.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/get_current_dart_package.dart';
import 'package:dev_tools/src/use_cases/git/get_current_branch.dart';

Future<void> main() async {
  const flutterCommandFinder = FindFvmAwareFlutterCommand();
  const dartCommandFinder = FindFvmAwareDartCommand();
  print('Flutter command: ${await flutterCommandFinder()}');
  print('Dart command: ${await dartCommandFinder()}');

  final root = await const FindProjectRoot()();
  print('Project root: $root');
  print('Dart package: ${await const GetCurrentDartPackage()(root)}');

  final branch = await const GetCurrentBranch()();
  print('Current branch: $branch');
}
