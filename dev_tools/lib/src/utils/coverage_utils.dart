import 'dart:io';

import 'package:dev_tools/src/dev_tools_exception.dart';
import 'package:dev_tools/src/utils/project_utils.dart';

/// Utilities for reading coverage data from an lcov file.
///
/// Mirrors `coverage_utils.sh`.
class CoverageUtils {
  final ProjectUtils _projectUtils;

  const CoverageUtils({ProjectUtils projectUtils = const ProjectUtils()})
    : _projectUtils = projectUtils;

  /// Parses the line coverage percentage (an integer such as `87`) from an
  /// lcov file using the `lcov --summary` command.
  ///
  /// Throws [CoverageException] if the lcov file does not exist or the
  /// percentage cannot be parsed.
  Future<int> getCoveragePct(String lcovFile, [String? projectRoot]) async {
    final root = projectRoot ?? await _projectUtils.findProjectRoot();
    final file = File('$root/$lcovFile');
    if (!file.existsSync()) {
      throw CoverageException('Error: coverage file not found: $lcovFile.');
    }

    final result = await Process.run('lcov', ['--summary', file.path]);
    final output = '${result.stdout}${result.stderr}';
    final match = RegExp(r'lines\.*:\s*(\d+\.?\d*)%').firstMatch(output);
    if (match == null) {
      throw const CoverageException('Error: Could not parse coverage data.');
    }
    return double.parse(match.group(1)!).round();
  }
}

/// Base exception for coverage operations.
class CoverageException extends DevToolsException {
  const CoverageException(super.message);
}
