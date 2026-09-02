import 'dart:io';

import 'package:dev_tools/src/utils/cmd_installation_checker.dart';
import 'package:dev_tools/src/utils/project_utils.dart';

/// Filters raw coverage data and generates an HTML report.
///
/// Mirrors `process_coverage_data.sh`.
class ProcessCoverageData {
  final ProjectUtils _projectUtils;
  final CmdInstallationChecker _cmdInstallationChecker;

  const ProcessCoverageData({
    ProjectUtils projectUtils = const ProjectUtils(),
    CmdInstallationChecker cmdInstallationChecker =
        const CmdInstallationChecker(),
  }) : _projectUtils = projectUtils,
       _cmdInstallationChecker = cmdInstallationChecker;

  /// Removes [exclude] patterns from `coverage/lcov.info` with `lcov` and,
  /// when `genhtml` is available, generates an HTML report in
  /// `coverage/html`.
  ///
  /// Degrades gracefully: when `lcov` is missing the step is skipped with a
  /// warning instead of failing.
  Future<void> call({List<String> exclude = const []}) async {
    final root = await _projectUtils.findProjectRoot();

    if (!await _cmdInstallationChecker.isOnPath('lcov')) {
      stderr.writeln(
        'Warning: lcov not found — skipping coverage report generation.',
      );
      return;
    }

    await Process.run('lcov', [
      '--remove',
      '$root/coverage/lcov.info',
      '--output-file',
      '$root/coverage/lcov.info',
      ...exclude,
    ]);

    if (await _cmdInstallationChecker.isOnPath('genhtml')) {
      await Process.run('genhtml', [
        '$root/coverage/lcov.info',
        '-o',
        '$root/coverage/html',
      ]);
    }
  }
}
