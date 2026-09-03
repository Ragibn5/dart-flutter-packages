import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/use_cases/check_coverage_with_threshold.dart';

class CheckCoverageCommand extends Command<void> {
  final CheckCoverageWithThreshold _checkCoverage;

  CheckCoverageCommand({CheckCoverageWithThreshold? checkCoverage})
    : _checkCoverage = checkCoverage ?? CheckCoverageWithThreshold();

  @override
  String get name => 'check';

  @override
  String get description => 'Enforce the coverage threshold (default 100%).';

  @override
  FutureOr<void>? run() {
    final rest = argResults!.rest;
    final lcovFile = rest.isNotEmpty ? rest[0] : 'coverage/lcov.info';
    final threshold =
        rest.length > 1 ? double.tryParse(rest[1]) ?? 100.0 : 100.0;
    return _checkCoverage(lcovFile: lcovFile, threshold: threshold);
  }
}
