import 'package:dev_tools/src/utils/coverage_utils.dart';
import 'package:dev_tools/src/utils/project_utils.dart';

/// Enforces a minimum line coverage threshold.
///
/// Mirrors `check_coverage.sh`.
class CheckCoverage {
  final ProjectUtils _projectUtils;
  final CoverageUtils _coverageUtils;

  const CheckCoverage({
    ProjectUtils projectUtils = const ProjectUtils(),
    CoverageUtils coverageUtils = const CoverageUtils(),
  }) : _projectUtils = projectUtils,
       _coverageUtils = coverageUtils;

  /// Verifies that the line coverage of [lcovFile] is at least [threshold].
  ///
  /// Throws [CoverageThresholdException] when coverage is below the threshold
  /// or the data cannot be parsed.
  Future<void> call({
    String lcovFile = 'coverage/lcov.info',
    double threshold = 100,
  }) async {
    final root = await _projectUtils.findProjectRoot();
    final pct = await _coverageUtils.getCoveragePct(lcovFile, root);
    if (pct < threshold) {
      throw CoverageThresholdException(
        'ERROR: Coverage $pct% is below required ${_fmt(threshold)}%.\n'
        "       Make sure you ran 'make run-tests-with-coverage "
        "&& make process-coverage-data' first for fresh coverage data.",
      );
    }
  }

  String _fmt(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }
}

/// Thrown when coverage is below the enforced threshold.
class CoverageThresholdException extends CoverageException {
  const CoverageThresholdException(super.message);
}
