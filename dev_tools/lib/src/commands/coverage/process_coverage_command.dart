import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/use_cases/process_coverage_data.dart';

class ProcessCoverageCommand extends Command<void> {
  static const String commandName = 'process';
  static const String commandDescription =
      'Filter lcov data using exclusion patterns.';

  final ProcessCoverageDataWithLcov _processCoverageData;

  ProcessCoverageCommand({
    ProcessCoverageDataWithLcov processCoverageData =
        const ProcessCoverageDataWithLcov(),
  }) : _processCoverageData = processCoverageData;

  @override
  String get name => commandName;

  @override
  String get description => commandDescription;

  @override
  FutureOr<void>? run() => _processCoverageData(exclusions: argResults!.rest);
}
