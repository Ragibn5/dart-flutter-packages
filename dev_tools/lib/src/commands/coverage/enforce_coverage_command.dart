import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/use_cases/coverage/check_coverage_with_threshold.dart';

class EnforceCoverageCommand extends Command<void> {
  static const String commandName = 'enforce';
  static const String lcovFileOption = 'lcov-file';
  static const String thresholdOption = 'threshold';
  static const String commandDescription =
      'Enforce the coverage threshold against an lcov file (default 100%). '
      'The lcov file path is relative to the project root (default coverage/lcov.info) and the threshold is a percentage.';

  final EnforceCoverageThreshold _checkCoverage;

  EnforceCoverageCommand({EnforceCoverageThreshold? checkCoverage})
      : _checkCoverage = checkCoverage ?? EnforceCoverageThreshold() {
    argParser
      ..addOption(
        lcovFileOption,
        defaultsTo: 'coverage/lcov.info',
        help: 'Path to the lcov file, relative to the project root.',
      )
      ..addOption(
        thresholdOption,
        defaultsTo: '100',
        help: 'Coverage percentage.',
      );
  }

  @override
  String get name => commandName;

  @override
  String get description => commandDescription;

  @override
  FutureOr<void>? run() {
    final lcovFile = argResults![lcovFileOption] as String;
    final threshold =
        double.tryParse(argResults![thresholdOption] as String) ?? 100.0;
    return _checkCoverage(lcovFile: lcovFile, threshold: threshold);
  }
}
