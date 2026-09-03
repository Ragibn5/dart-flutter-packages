// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:dev_tools/src/use_cases/find_project_root.dart';
import 'package:dev_tools/src/use_cases/fvm_aware_flutter_command_finder.dart';
import 'package:dev_tools/src/use_cases/run_flutter_test_with_coverage.dart';
import 'package:test/test.dart';

class _FakeFindProjectRoot extends FindProjectRoot {
  const _FakeFindProjectRoot(this.root);

  final String root;

  @override
  Future<String> call([String? start]) async => root;
}

class _FakeFlutterFinder extends FvmAwareFlutterCommandFinder {
  _FakeFlutterFinder(this.command);

  String command;

  @override
  Future<String> call() async => command;
}

void main() {
  late Directory tempDir;

  late _FakeFindProjectRoot findProjectRoot;
  late _FakeFlutterFinder flutterFinder;

  late RunFlutterTestWithCoverage sut;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('run_flutter_project');
    findProjectRoot = _FakeFindProjectRoot(tempDir.path);
    flutterFinder = _FakeFlutterFinder(_script(tempDir, exitCode: 0));

    sut = RunFlutterTestWithCoverage(
      findProjectRoot: findProjectRoot,
      flutterCommandFinder: flutterFinder,
    );
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('should not throw when the flutter test command exits with zero',
      () async {
    await expectLater(sut(), completes);
  });

  test(
    'should throw FlutterTestWithCoverageException when the command fails',
    () async {
      flutterFinder.command = _script(tempDir, exitCode: 1);

      await expectLater(
        sut(),
        throwsA(isA<FlutterTestWithCoverageException>()),
      );
    },
  );
}

String _script(Directory dir, {required int exitCode}) {
  final script = File('${dir.path}/cmd.sh')
    ..writeAsStringSync('#!/bin/sh\nexit $exitCode\n');
  Process.runSync('chmod', ['+x', script.path]);
  return script.path;
}
