// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:dev_tools/src/exceptions/command_not_found_exception.dart';
import 'package:dev_tools/src/use_cases/coverage/process_coverage_data.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_project_root.dart';
import 'package:dev_tools/src/use_cases/shell_utils/cmd_installation_checker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockFindProjectRoot extends Mock implements FindProjectRoot {}

class _MockCmdChecker extends Mock implements CmdInstallationChecker {}

bool _toolNotAvailable(String tool) =>
    Process.runSync('which', [tool]).exitCode != 0;

void main() {
  late Directory tempDir;
  late _MockFindProjectRoot findProjectRoot;
  late _MockCmdChecker cmdChecker;

  late ProcessCoverageDataWithLcov sut;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('process_coverage_data_test');
    findProjectRoot = _MockFindProjectRoot();
    cmdChecker = _MockCmdChecker();

    when(() => findProjectRoot()).thenAnswer((_) async => tempDir.path);

    sut = ProcessCoverageDataWithLcov(
      findProjectRoot: findProjectRoot,
      cmdInstallationChecker: cmdChecker,
    );
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test(
    'should throw CommandNotFoundException when lcov is not installed',
    () async {
      when(() => cmdChecker(any())).thenAnswer((_) async => false);

      await expectLater(sut(), throwsA(isA<CommandNotFoundException>()));
    },
  );

  test(
    'should run lcov when it is installed',
    () async {
      when(() => cmdChecker(any())).thenAnswer((_) async => true);
      Directory('${tempDir.path}/coverage').createSync(recursive: true);
      File('${tempDir.path}/coverage/lcov.info').writeAsStringSync(
        'SF:lib/foo.dart\nDA:1,1\nend_of_record\n',
      );

      await expectLater(sut(), completes);
    },
    skip: _toolNotAvailable('lcov') ? 'lcov not available' : null,
  );

  test(
    'should throw LcovFilteringException when lcov exits non-zero',
    () async {
      when(() => cmdChecker(any())).thenAnswer((_) async => true);
      // No coverage/lcov.info written, so lcov has nothing to read.

      await expectLater(sut(), throwsA(isA<LcovFilteringException>()));
    },
    skip: _toolNotAvailable('lcov') ? 'lcov not available' : null,
  );
}
