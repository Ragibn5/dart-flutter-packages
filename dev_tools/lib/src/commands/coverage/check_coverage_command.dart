import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/use_cases/coverage/check_coverage_with_threshold.dart';

class CheckCoverageCommand extends Command<void> {
  static const String commandName = 'check';
  static const String commandDescription =
      'Enforce the coverage threshold against an lcov file (default 100%). '
      'The lcov file path is relative to the project root (default coverage/lcov.info) and the threshold is a percentage.';

  final EnforceCoverageThreshold _checkCoverage;

  CheckCoverageCommand({EnforceCoverageThreshold? checkCoverage})
      : _checkCoverage = checkCoverage ?? EnforceCoverageThreshold();

  @override
  String get name => commandName;

  @override
  String get description => commandDescription;

  @override
  FutureOr<void>? run() {
    final rest = argResults!.rest;
    final lcovFile = rest.isNotEmpty ? rest[0] : 'coverage/lcov.info';
    final threshold =
        rest.length > 1 ? double.tryParse(rest[1]) ?? 100.0 : 100.0;
    return _checkCoverage(lcovFile: lcovFile, threshold: threshold);
  }
}
