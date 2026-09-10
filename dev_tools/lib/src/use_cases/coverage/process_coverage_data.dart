import 'dart:io';

import 'package:dev_tools/src/exceptions/command_execution_exception.dart';
import 'package:dev_tools/src/exceptions/command_not_found_exception.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_project_root.dart';
import 'package:dev_tools/src/use_cases/shell_utils/cmd_installation_checker.dart';

class ProcessCoverageDataWithLcov {
  final FindProjectRoot _findProjectRoot;
  final CmdInstallationChecker _cmdInstallationChecker;

  const ProcessCoverageDataWithLcov({
    FindProjectRoot findProjectRoot = const FindProjectRoot(),
    CmdInstallationChecker cmdInstallationChecker =
        const CmdInstallationChecker(),
  })  : _findProjectRoot = findProjectRoot,
        _cmdInstallationChecker = cmdInstallationChecker;

  /// Filters lcov coverage data using exclusion patterns.
  ///
  /// Params:
  /// - `exclusions`: lcov removal patterns relative to the project root
  ///   (e.g. 'lib/api/**').
  ///
  /// Returns: nothing (void); writes the filtered data back to
  /// coverage/lcov.info.
  ///
  /// Throws:
  /// - [CommandNotFoundException] when lcov is not installed.
  /// - [ProjectRootNotFoundException] when no project root can be found.
  /// - [LcovFilteringException] when `lcov --remove` exits with a non-zero
  ///   code.
  Future<void> call({List<String> exclusions = const []}) async {
    final root = await _findProjectRoot();
    if (!await _cmdInstallationChecker('lcov')) {
      throw const CommandNotFoundException(['lcov']);
    }

    final result = await Process.run('lcov', [
      '--remove',
      '$root/coverage/lcov.info',
      '--output-file',
      '$root/coverage/lcov.info',
      ...exclusions,
    ]);
    if (result.exitCode != 0) {
      throw LcovFilteringException(
        'Error(${result.exitCode}): lcov --remove failed.\n${result.stderr}',
      );
    }

    stdout.writeln('Coverage data filtered at coverage/lcov.info.');
  }
}

class LcovFilteringException extends CommandExecutionException {
  @override
  final String message;

  const LcovFilteringException(this.message);
}
