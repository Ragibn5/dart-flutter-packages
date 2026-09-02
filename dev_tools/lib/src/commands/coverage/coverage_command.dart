import 'package:args/command_runner.dart';
import 'package:dev_tools/src/commands/coverage/check_coverage_command.dart';
import 'package:dev_tools/src/commands/coverage/process_coverage_command.dart';
import 'package:dev_tools/src/commands/coverage/run_coverage_command.dart';

class CoverageCommand extends Command<void> {
  CoverageCommand() {
    addSubcommand(RunCoverageCommand());
    addSubcommand(ProcessCoverageCommand());
    addSubcommand(CheckCoverageCommand());
  }

  @override
  String get name => 'coverage';

  @override
  String get description =>
      'Run tests with coverage, process coverage data and enforce thresholds.';
}
