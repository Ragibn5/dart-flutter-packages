import 'package:dev_tools/src/commands/coverage/check_coverage_command.dart';
import 'package:dev_tools/src/commands/coverage/coverage_command.dart';
import 'package:dev_tools/src/commands/coverage/generate_coverage_report_command.dart';
import 'package:dev_tools/src/commands/coverage/process_coverage_command.dart';
import 'package:dev_tools/src/commands/coverage/run_coverage_command.dart';
import 'package:test/test.dart';

void main() {
  late CoverageCommand sut;

  setUp(() {
    sut = CoverageCommand();
  });

  test('should expose the coverage name', () {
    expect(sut.name, CoverageCommand.commandName);
  });

  test(
    'should describe running tests with coverage and enforcing thresholds',
    () {
      expect(sut.description, CoverageCommand.commandDescription);
    },
  );

  test('should register the run, process, genreport and check subcommands', () {
    expect(
      sut.subcommands.keys,
      containsAll(<String>[
        RunCoverageCommand.commandName,
        ProcessCoverageCommand.commandName,
        GenerateCoverageReportCommand.commandName,
        CheckCoverageCommand.commandName,
      ]),
    );
    expect(sut.subcommands[RunCoverageCommand.commandName],
        isA<RunCoverageCommand>());
    expect(sut.subcommands[ProcessCoverageCommand.commandName],
        isA<ProcessCoverageCommand>());
    expect(sut.subcommands[GenerateCoverageReportCommand.commandName],
        isA<GenerateCoverageReportCommand>());
    expect(sut.subcommands[CheckCoverageCommand.commandName],
        isA<CheckCoverageCommand>());
  });
}
