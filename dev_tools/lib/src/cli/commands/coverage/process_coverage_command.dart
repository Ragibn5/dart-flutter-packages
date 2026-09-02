import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/utils/process_coverage_data.dart';

/// Filters coverage data and generates an HTML report.
class ProcessCoverageCommand extends Command<void> {
  final ProcessCoverageData _processCoverageData;

  ProcessCoverageCommand({
    ProcessCoverageData processCoverageData = const ProcessCoverageData(),
  }) : _processCoverageData = processCoverageData;

  @override
  String get name => 'process';

  @override
  String get description => 'Filter lcov data and generate an HTML report.';

  @override
  FutureOr<void>? run() async => _processCoverageData();
}
