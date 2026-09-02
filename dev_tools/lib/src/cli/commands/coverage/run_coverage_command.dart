import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/utils/run_test_with_coverage.dart';

/// Runs the project tests with coverage enabled.
class RunCoverageCommand extends Command<void> {
  final RunTestWithCoverage _runTestWithCoverage;

  RunCoverageCommand({
    RunTestWithCoverage runTestWithCoverage = const RunTestWithCoverage(),
  }) : _runTestWithCoverage = runTestWithCoverage;

  @override
  String get name => 'run';

  @override
  String get description => 'Run tests with coverage, writing to lcov.info.';

  @override
  FutureOr<void>? run() async => _runTestWithCoverage();
}
