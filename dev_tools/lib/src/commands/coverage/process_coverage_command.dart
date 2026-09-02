import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/use_cases/process_coverage_data.dart';

class ProcessCoverageCommand extends Command<void> {
  final ProcessCoverageDataWithLcov _processCoverageData;

  ProcessCoverageCommand({
    ProcessCoverageDataWithLcov processCoverageData =
        const ProcessCoverageDataWithLcov(),
  }) : _processCoverageData = processCoverageData;

  @override
  String get name => 'process';

  @override
  String get description => 'Filter lcov data and generate an HTML report.';

  @override
  FutureOr<void>? run() async => _processCoverageData();
}
