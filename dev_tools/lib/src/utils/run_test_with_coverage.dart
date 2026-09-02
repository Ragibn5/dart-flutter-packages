import 'dart:io';

import 'package:dev_tools/src/utils/coverage_utils.dart';
import 'package:dev_tools/src/utils/flutter_command_finder.dart';
import 'package:dev_tools/src/utils/project_utils.dart';

/// Runs the project tests with coverage enabled.
///
/// Mirrors `run_test_with_coverage.sh`.
class RunTestWithCoverage {
  final ProjectUtils _projectUtils;
  final FlutterCommandFinder _findFlutterCommand;

  const RunTestWithCoverage({
    ProjectUtils projectUtils = const ProjectUtils(),
    FlutterCommandFinder flutterCommandFinder = const FlutterCommandFinder(),
  }) : _projectUtils = projectUtils,
       _findFlutterCommand = flutterCommandFinder;

  /// Runs `flutter test --no-test-assets --coverage`, writing the raw lcov
  /// data to `coverage/lcov.info` inside the project root.
  ///
  /// Throws [CoverageException] if the tests cannot be run.
  Future<void> call() async {
    final root = await _projectUtils.findProjectRoot();
    final flutterCmd = await _findFlutterCommand();
    final parts = flutterCmd.split(' ');
    final result = await Process.run(parts.first, [
      ...parts.skip(1),
      'test',
      '--no-test-assets',
      '--coverage',
      '--coverage-path',
      'coverage/lcov.info',
    ], workingDirectory: root);
    if (result.exitCode != 0) {
      throw CoverageException(
        'Error: flutter test with coverage failed.\n'
        '${result.stdout}${result.stderr}',
      );
    }
  }
}
