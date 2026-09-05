import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/use_cases/coverage/generate_coverage_report_page.dart';

class GenerateCoverageReportCommand extends Command<void> {
  static const String commandName = 'genreport';
  static const String commandDescription =
      'Generate an HTML coverage report with genhtml.';

  final GenerateCoverageReportPage _generateCoverageReport;

  GenerateCoverageReportCommand({
    GenerateCoverageReportPage generateCoverageReport =
        const GenerateCoverageReportPage(),
  }) : _generateCoverageReport = generateCoverageReport;

  @override
  String get name => commandName;

  @override
  String get description => commandDescription;

  @override
  FutureOr<void>? run() => _generateCoverageReport();
}
