// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:dev_tools/src/exceptions/command_not_found_exception.dart';
import 'package:dev_tools/src/use_cases/common/cmd_installation_checker.dart';
import 'package:dev_tools/src/use_cases/common/find_project_root.dart';
import 'package:dev_tools/src/use_cases/coverage/process_coverage_data.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockFindProjectRoot extends Mock implements FindProjectRoot {}

class _MockCmdChecker extends Mock implements CmdInstallationChecker {}

bool _toolNotAvailable(String tool) =>
    Process.runSync('which', [tool]).exitCode != 0;

void main() {
  const root = '/fake/root';

  late _MockFindProjectRoot findProjectRoot;
  late _MockCmdChecker cmdChecker;

  late ProcessCoverageDataWithLcov sut;

  setUp(() {
    findProjectRoot = _MockFindProjectRoot();
    cmdChecker = _MockCmdChecker();

    when(() => findProjectRoot()).thenAnswer((_) async => root);

    sut = ProcessCoverageDataWithLcov(
      findProjectRoot: findProjectRoot,
      cmdInstallationChecker: cmdChecker,
    );
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

      await expectLater(sut(exclusions: ['lib/generated/*']), completes);
    },
    skip: _toolNotAvailable('lcov') ? 'lcov not available' : null,
  );
}
