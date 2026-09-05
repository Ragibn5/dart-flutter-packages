// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:dev_tools/src/use_cases/common/find_fvm_aware_flutter_command.dart';
import 'package:dev_tools/src/use_cases/common/find_project_root.dart';
import 'package:dev_tools/src/use_cases/coverage/run_flutter_test_with_coverage.dart';
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

  test(
    'should include the exit code in the FlutterTestWithCoverageException message',
    () async {
      when(() => flutterCommandFinder())
          .thenAnswer((_) async => _script(tempDir, exitCode: 1));

      try {
        await sut();
        fail('expected FlutterTestWithCoverageException to be thrown');
      } on FlutterTestWithCoverageException catch (error) {
        expect(error.toString(), contains('Error(1)'));
      }
    },
  );

  test('should pass a custom lcov file path to the flutter test command',
      () async {
    final logFile = '${tempDir.path}/args.log';
    when(() => flutterCommandFinder()).thenAnswer(
        (_) async => _script(tempDir, exitCode: 0, logFile: logFile));

    await sut(lcovFile: 'coverage/alt.info');

    final args = File(logFile).readAsStringSync();
    expect(args, contains('--coverage-path'));
    expect(args, contains('coverage/alt.info'));
  });

  group('splitCommand', () {
    test('should use the whole command as the executable for flutter', () {
      final command = RunFlutterTestWithCoverage.splitCommand('flutter');
      expect(command.executable, 'flutter');
      expect(command.arguments, isEmpty);
    });

    test(
      'should split the fvm prefix into executable and leading argument',
      () {
        final command = RunFlutterTestWithCoverage.splitCommand('fvm flutter');
        expect(command.executable, 'fvm');
        expect(command.arguments, ['flutter']);
      },
    );

    test('should tolerate irregular and surrounding whitespace', () {
      final command =
          RunFlutterTestWithCoverage.splitCommand('  fvm\t  flutter  ');
      expect(command.executable, 'fvm');
      expect(command.arguments, ['flutter']);
    });

    test('should fall back to the whole command for arbitrary executables', () {
      final command = RunFlutterTestWithCoverage.splitCommand('/tmp/x/cmd.sh');
      expect(command.executable, '/tmp/x/cmd.sh');
      expect(command.arguments, isEmpty);
    });
  });
}

String _script(Directory dir, {required int exitCode, String? logFile}) {
  final buffer = StringBuffer('#!/bin/sh\n');
  if (logFile != null) {
    buffer.writeln('printf "%s\\n" "\$*" > "$logFile"');
  }
  buffer.writeln('exit $exitCode');
  final script = File('${dir.path}/cmd.sh')
    ..writeAsStringSync(buffer.toString());
  Process.runSync('chmod', ['+x', script.path]);
  return script.path;
}
