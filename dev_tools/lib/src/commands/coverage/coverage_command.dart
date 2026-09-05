import 'package:args/command_runner.dart';
import 'package:dev_tools/src/commands/coverage/check_coverage_command.dart';
import 'package:dev_tools/src/commands/coverage/generate_coverage_report_command.dart';
import 'package:dev_tools/src/commands/coverage/process_coverage_command.dart';
import 'package:dev_tools/src/commands/coverage/run_coverage_command.dart';

class CoverageCommand extends Command<void> {
  static const String commandName = 'coverage';
  static const String commandDescription = 'Coverage related commands.';

  CoverageCommand() {
    addSubcommand(RunCoverageCommand());
    addSubcommand(ProcessCoverageCommand());
    addSubcommand(GenerateCoverageReportCommand());
    addSubcommand(CheckCoverageCommand());
  }

  @override
  String get name => commandName;

  @override
  String get description => commandDescription;
}
