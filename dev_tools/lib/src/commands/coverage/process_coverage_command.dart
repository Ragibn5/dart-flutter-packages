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
  String get name => 'process-coverage';

  @override
  String get description => 'Filter lcov data using exclusion patterns.';

  @override
  FutureOr<void>? run() => _processCoverageData(exclusions: argResults!.rest);
}
