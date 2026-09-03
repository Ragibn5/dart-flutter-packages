// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:dev_tools/src/use_cases/find_fvm_aware_flutter_command.dart';
import 'package:dev_tools/src/use_cases/find_project_root.dart';
import 'package:dev_tools/src/use_cases/run_flutter_test_with_coverage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockFindProjectRoot extends Mock implements FindProjectRoot {}

class _MockFlutterCommandFinder extends Mock
    implements FindFvmAwareFlutterCommand {}

void main() {
  late Directory tempDir;

  late _MockFindProjectRoot findProjectRoot;
  late _MockFlutterCommandFinder flutterCommandFinder;

  late RunFlutterTestWithCoverage sut;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('run_flutter_project');
    findProjectRoot = _MockFindProjectRoot();
    flutterCommandFinder = _MockFlutterCommandFinder();

    when(() => findProjectRoot()).thenAnswer((_) async => tempDir.path);
    when(() => flutterCommandFinder())
        .thenAnswer((_) async => _script(tempDir, exitCode: 0));

    sut = RunFlutterTestWithCoverage(
      findProjectRoot: findProjectRoot,
      flutterCommandFinder: flutterCommandFinder,
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
      when(() => flutterCommandFinder())
          .thenAnswer((_) async => _script(tempDir, exitCode: 1));

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
