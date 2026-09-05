import 'dart:io';

import 'package:dev_tools/src/use_cases/dart_flutter/find_project_root.dart';

class CalculateCoverage {
  final FindProjectRoot _findProjectRoot;

  const CalculateCoverage({
    FindProjectRoot findProjectRoot = const FindProjectRoot(),
  }) : _findProjectRoot = findProjectRoot;

  /// Computes the line coverage reported in an lcov file.
  ///
  /// Params:
  /// - `lcovFile`: path to the lcov file, relative to [projectRoot] (or the
  ///   project root resolved from the current working directory).
  /// - `projectRoot`: absolute path to the project root (optional).
  ///
  /// Returns: the rounded line coverage percentage.
  ///
  /// Notes: throws [CoverageCalculationException] when the file is missing
  /// or its summary cannot be parsed.
  Future<int> call(String lcovFile, [String? projectRoot]) async {
    final root = projectRoot ?? await _findProjectRoot();
    final file = File('$root/$lcovFile');
    if (!file.existsSync()) {
      throw CoverageCalculationException(
        'Error: coverage file not found: $lcovFile.',
      );
    }

    final result = await Process.run('lcov', ['--summary', file.path]);
    final output = '${result.stdout}${result.stderr}';
    final match = RegExp(r'lines\.*:\s*(\d+\.?\d*)%').firstMatch(output);
    if (match == null) {
      throw const CoverageCalculationException(
        'Error: Could not parse coverage data.',
      );
    }

    return double.parse(match.group(1)!).round();
  }
}

class CoverageCalculationException implements Exception {
  final String message;

  const CoverageCalculationException(this.message);
}
