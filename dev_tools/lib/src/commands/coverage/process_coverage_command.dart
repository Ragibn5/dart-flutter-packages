import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/use_cases/coverage/process_coverage_data.dart';

class ProcessCoverageCommand extends Command<void> {
  static const String commandName = 'process';
  static const String excludeOption = 'exclude';
  static const String commandDescription =
      'Filter lcov data using exclusion patterns relative to the project root (e.g. lib/api/**).';

  final ProcessCoverageDataWithLcov _processCoverageData;

  ProcessCoverageCommand({
    ProcessCoverageDataWithLcov processCoverageData =
        const ProcessCoverageDataWithLcov(),
  }) : _processCoverageData = processCoverageData {
    argParser.addMultiOption(
      excludeOption,
      abbr: 'e',
      help: 'Exclusion pattern relative to the project root (e.g. lib/api/**).',
    );
  }

  @override
  String get name => commandName;

  @override
  String get description => commandDescription;

  @override
  FutureOr<void>? run() async {
    final exclusions = argResults![excludeOption] as List<String>;
    await _processCoverageData(exclusions: exclusions);
  }
}
