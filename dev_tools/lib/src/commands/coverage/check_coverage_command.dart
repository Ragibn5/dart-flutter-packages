import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/use_cases/check_coverage_with_threshold.dart';

class CheckCoverageCommand extends Command<void> {
  final CheckCoverageWithThreshold _checkCoverage;

  CheckCoverageCommand(
      {CheckCoverageWithThreshold checkCoverage =
          const CheckCoverageWithThreshold()})
      : _checkCoverage = checkCoverage;

  @override
  String get name => 'check';

  @override
  String get description => 'Enforce the coverage threshold (default 100%).';

  @override
  FutureOr<void>? run() async {
    final rest = argResults!.rest;
    final lcovFile = rest.isNotEmpty ? rest[0] : 'coverage/lcov.info';
    final threshold =
        rest.length > 1 ? double.tryParse(rest[1]) ?? 100.0 : 100.0;
    await _checkCoverage(lcovFile: lcovFile, threshold: threshold);
    stdout.writeln('Coverage meets required ${_fmt(threshold)}%.');
  }

  String _fmt(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }
}
