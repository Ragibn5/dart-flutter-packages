import 'dart:io';

import 'package:dev_tools/src/use_cases/find_project_root.dart';
import 'package:dev_tools/src/use_cases/fvm_aware_flutter_command_finder.dart';
import 'package:dev_tools/src/use_cases/run_flutter_test_with_coverage.dart';
import 'package:test/test.dart';

void main() {
  test(
    'should not throw when the flutter test command exits with zero',
    () async {
      final dir = await _setupProject();
      final useCase = RunFlutterTestWithCoverage(
        findProjectRoot: _FakeFindProjectRoot(dir.path),
        flutterCommandFinder: _FakeFlutterFinder(_script(dir)),
      );
      await expectLater(useCase(), completes);
    },
  );

  test(
    'should throw FlutterTestWithCoverageException when the command fails',
    () async {
      final dir = await _setupProject();
      final useCase = RunFlutterTestWithCoverage(
        findProjectRoot: _FakeFindProjectRoot(dir.path),
        flutterCommandFinder: _FakeFlutterFinder(_script(dir, exitCode: 1)),
      );
      await expectLater(
        useCase(),
        throwsA(isA<FlutterTestWithCoverageException>()),
      );
    },
  );
}

String _script(Directory dir, {int exitCode = 0}) {
  final script = File('${dir.path}/cmd.sh')
    ..writeAsStringSync('#!/bin/sh\nexit $exitCode\n');
  Process.runSync('chmod', ['+x', script.path]);
  return script.path;
}

Future<Directory> _setupProject() async {
  final dir = Directory.systemTemp.createTempSync('run_flutter_project');
  addTearDown(() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });
  return dir;
}

class _FakeFindProjectRoot extends FindProjectRoot {
  const _FakeFindProjectRoot(this.root);

  final String root;

  @override
  Future<String> call([String? start]) async => root;
}

class _FakeFlutterFinder extends FvmAwareFlutterCommandFinder {
  const _FakeFlutterFinder(this.command);

  final String command;

  @override
  Future<String> call() async => command;
}
