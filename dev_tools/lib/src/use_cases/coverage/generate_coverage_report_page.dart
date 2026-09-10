import 'dart:io';

import 'package:dev_tools/src/exceptions/command_not_found_exception.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_project_root.dart';
import 'package:dev_tools/src/use_cases/shell_utils/cmd_installation_checker.dart';

class GenerateCoverageReportPage {
  final FindProjectRoot _findProjectRoot;
  final CmdInstallationChecker _cmdInstallationChecker;

  const GenerateCoverageReportPage({
    FindProjectRoot findProjectRoot = const FindProjectRoot(),
    CmdInstallationChecker cmdInstallationChecker =
        const CmdInstallationChecker(),
  })  : _findProjectRoot = findProjectRoot,
        _cmdInstallationChecker = cmdInstallationChecker;

  /// Generates an HTML coverage report from lcov data.
  ///
  /// Params:
  /// - `exclusions`: unused; accepted for parity with the other coverage
  ///   commands.
  ///
  /// Returns: nothing (void); writes the report to `coverage/html/`.
  ///
  /// Throws:
  /// - [CommandNotFoundException] when genhtml is not installed.
  /// - [ProjectRootNotFoundException] when no project root can be found.
  Future<void> call({List<String> exclusions = const []}) async {
    final root = await _findProjectRoot();
    if (!await _cmdInstallationChecker('genhtml')) {
      throw const CommandNotFoundException(['genhtml']);
    }

    await Process.run('genhtml', [
      '$root/coverage/lcov.info',
      '-o',
      '$root/coverage/html',
    ]);

    stdout.writeln('HTML report generated at coverage/html/.');
  }
}
