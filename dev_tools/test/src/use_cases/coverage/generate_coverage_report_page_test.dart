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
  late Directory tempDir;
  late _MockFindProjectRoot findProjectRoot;
  late _MockCmdChecker cmdChecker;

  late GenerateCoverageReportPage sut;

  setUp(() {
    tempDir = Directory.systemTemp
        .createTempSync('generate_coverage_report_page_test');
    findProjectRoot = _MockFindProjectRoot();
    cmdChecker = _MockCmdChecker();

    when(() => findProjectRoot()).thenAnswer((_) async => tempDir.path);
    when(() => cmdChecker(any())).thenAnswer((_) async => true);

    sut = GenerateCoverageReportPage(
      findProjectRoot: findProjectRoot,
      cmdInstallationChecker: cmdChecker,
    );
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
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
      Directory('${tempDir.path}/coverage').createSync(recursive: true);
      // References a real, checked-in source file (relative to the package
      // root, which is the test runner's cwd) so genhtml can read its
      // content to annotate line coverage.
      File('${tempDir.path}/coverage/lcov.info').writeAsStringSync(
        'TN:\nSF:lib/src/models/release_issue.dart\nDA:1,1\nend_of_record\n',
      );

      await expectLater(sut(), completes);
    },
    skip: _toolNotAvailable('genhtml') ? 'genhtml not available' : null,
  );

  test(
    'should throw CoverageReportGenerationException when genhtml exits '
    'non-zero',
    () async {
      // No coverage/lcov.info written, so genhtml has nothing to read.

      await expectLater(
        sut(),
        throwsA(isA<CoverageReportGenerationException>()),
      );
    },
    skip: _toolNotAvailable('genhtml') ? 'genhtml not available' : null,
  );
}
