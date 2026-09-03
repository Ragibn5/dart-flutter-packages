// ignore_for_file: lines_longer_than_80_chars

import 'package:dev_tools/src/use_cases/calculate_coverage.dart';
import 'package:dev_tools/src/use_cases/find_project_root.dart';

class CheckCoverageWithThreshold {
  final FindProjectRoot _findProjectRoot;
  final CalculateCoverage _coverageUtils;

  const CheckCoverageWithThreshold({
    FindProjectRoot findProjectRoot = const FindProjectRoot(),
    CalculateCoverage coverageUtils = const CalculateCoverage(),
  })  : _findProjectRoot = findProjectRoot,
        _coverageUtils = coverageUtils;

  Future<void> call({
    String lcovFile = 'coverage/lcov.info',
    double threshold = 100,
  }) async {
    final root = await _findProjectRoot();
    final pct = await _coverageUtils.call(lcovFile, root);
    if (pct < threshold) {
      throw CheckCoverageWithThresholdException(
        'ERROR: Coverage $pct% is below required ${_fmt(threshold)}%.\n'
        '       Make sure you ran the tests with coverage and processed the coverage data first for fresh coverage data.',
      );
    }
  }

  String _fmt(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }
}

class CheckCoverageWithThresholdException implements Exception {
  final String message;

  const CheckCoverageWithThresholdException(this.message);

  @override
  String toString() => message;
}
