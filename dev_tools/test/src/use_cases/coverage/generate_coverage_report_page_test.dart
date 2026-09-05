// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:dev_tools/src/exceptions/command_not_found_exception.dart';
import 'package:dev_tools/src/use_cases/coverage/generate_coverage_report_page.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_project_root.dart';
import 'package:dev_tools/src/use_cases/shell_utils/cmd_installation_checker.dart';
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

  late GenerateCoverageReportPage sut;

  setUp(() {
    findProjectRoot = _MockFindProjectRoot();
    cmdChecker = _MockCmdChecker();

    when(() => findProjectRoot()).thenAnswer((_) async => root);
    when(() => cmdChecker(any())).thenAnswer((_) async => true);

    sut = GenerateCoverageReportPage(
      findProjectRoot: findProjectRoot,
      cmdInstallationChecker: cmdChecker,
    );
  });

  test(
    'should throw CommandNotFoundException when genhtml is not installed',
    () async {
      when(() => cmdChecker(any())).thenAnswer((_) async => false);

      await expectLater(sut(), throwsA(isA<CommandNotFoundException>()));
    },
  );

  test(
    'should run genhtml when it is installed',
    () async {
      await expectLater(sut(), completes);
    },
    skip: _toolNotAvailable('genhtml') ? 'genhtml not available' : null,
  );
}
