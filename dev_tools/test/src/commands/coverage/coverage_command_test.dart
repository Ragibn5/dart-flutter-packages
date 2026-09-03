import 'package:dev_tools/src/commands/coverage/check_coverage_command.dart';
import 'package:dev_tools/src/commands/coverage/coverage_command.dart';
import 'package:dev_tools/src/commands/coverage/process_coverage_command.dart';
import 'package:dev_tools/src/commands/coverage/run_coverage_command.dart';
import 'package:test/test.dart';

void main() {
  test('should expose the coverage name', () {
    expect(CoverageCommand().name, 'coverage');
  });

  test(
    'should describe running tests with coverage and enforcing thresholds',
    () {
      expect(CoverageCommand().description, contains('coverage'));
    },
  );

  test('should register the run, process and check subcommands', () {
    final cmd = CoverageCommand();
    expect(
      cmd.subcommands.keys,
      containsAll(<String>['run', 'process', 'check']),
    );
    expect(cmd.subcommands['run'], isA<RunCoverageCommand>());
    expect(cmd.subcommands['process'], isA<ProcessCoverageCommand>());
    expect(cmd.subcommands['check'], isA<CheckCoverageCommand>());
  });
}
