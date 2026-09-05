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
