import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/use_cases/coverage/run_flutter_test_with_coverage.dart';

class RunCoverageCommand extends Command<void> {
  static const String commandName = 'run';
  static const String lcovFileOption = 'lcov-file';
  static const String commandDescription = 'Run tests with coverage. '
      'The lcov output path is relative to the project root (default coverage/lcov.info).';

  final RunFlutterTestWithCoverage _runTestWithCoverage;

  RunCoverageCommand({
    RunFlutterTestWithCoverage runTestWithCoverage =
        const RunFlutterTestWithCoverage(),
  }) : _runTestWithCoverage = runTestWithCoverage {
    argParser.addOption(
      lcovFileOption,
      defaultsTo: 'coverage/lcov.info',
      help: 'Output path of the lcov file, relative to the project root.',
    );
  }

  @override
  String get name => commandName;

  @override
  String get description => commandDescription;

  @override
  FutureOr<void>? run() {
    final lcovFile = argResults![lcovFileOption] as String;
    return _runTestWithCoverage(lcovFile: lcovFile);
  }
}
