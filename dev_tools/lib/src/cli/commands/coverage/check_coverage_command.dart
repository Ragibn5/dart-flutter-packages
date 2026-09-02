import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/utils/check_coverage.dart';

/// Enforces a minimum line coverage threshold.
class CheckCoverageCommand extends Command<void> {
  final CheckCoverage _checkCoverage;

  CheckCoverageCommand({CheckCoverage checkCoverage = const CheckCoverage()})
    : _checkCoverage = checkCoverage;

  @override
  String get name => 'check';

  @override
  String get description => 'Enforce the coverage threshold (default 100%).';

  @override
  FutureOr<void>? run() async {
    final rest = argResults!.rest;
    final lcovFile = rest.isNotEmpty ? rest[0] : 'coverage/lcov.info';
    final threshold = rest.length > 1
        ? double.tryParse(rest[1]) ?? 100.0
        : 100.0;
    await _checkCoverage(lcovFile: lcovFile, threshold: threshold);
    stdout.writeln('Coverage meets required ${_fmt(threshold)}%.');
  }
}

String _fmt(double value) {
  return value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();
}
