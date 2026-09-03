import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/use_cases/run_flutter_test_with_coverage.dart';

class RunCoverageCommand extends Command<void> {
  final RunFlutterTestWithCoverage _runTestWithCoverage;

  RunCoverageCommand({
    RunFlutterTestWithCoverage runTestWithCoverage =
        const RunFlutterTestWithCoverage(),
  }) : _runTestWithCoverage = runTestWithCoverage;

  @override
  String get name => 'run';

  @override
  String get description => 'Run tests with coverage, writing to lcov.info.';

  @override
  FutureOr<void>? run() => _runTestWithCoverage();
}
