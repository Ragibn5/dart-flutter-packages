import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/use_cases/coverage/run_flutter_test_with_coverage.dart';

class RunCoverageCommand extends Command<void> {
  static const String commandName = 'run';
  static const String commandDescription =
      'Run tests with coverage, writing to lcov.info.';

  final RunFlutterTestWithCoverage _runTestWithCoverage;

  RunCoverageCommand({
    RunFlutterTestWithCoverage runTestWithCoverage =
        const RunFlutterTestWithCoverage(),
  }) : _runTestWithCoverage = runTestWithCoverage;

  @override
  String get name => commandName;

  @override
  String get description => commandDescription;

  @override
  FutureOr<void>? run() => _runTestWithCoverage();
}
