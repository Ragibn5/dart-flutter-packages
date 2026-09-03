import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/use_cases/generate_coverage_report_page.dart';

class GenerateCoverageReportCommand extends Command<void> {
  final GenerateCoverageReportPage _generateCoverageReport;

  GenerateCoverageReportCommand({
    GenerateCoverageReportPage generateCoverageReport =
        const GenerateCoverageReportPage(),
  }) : _generateCoverageReport = generateCoverageReport;

  @override
  String get name => 'generate-coverage-report';

  @override
  String get description => 'Generate an HTML coverage report with genhtml.';

  @override
  FutureOr<void>? run() => _generateCoverageReport();
}
