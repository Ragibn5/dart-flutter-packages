import 'package:dev_tools/src/commands/coverage/check_coverage_command.dart';
import 'package:dev_tools/src/commands/coverage/coverage_command.dart';
import 'package:dev_tools/src/commands/coverage/process_coverage_command.dart';
import 'package:dev_tools/src/commands/coverage/run_coverage_command.dart';
import 'package:test/test.dart';

void main() {
  late CoverageCommand sut;

  setUp(() {
    sut = CoverageCommand();
  });

  test('should expose the coverage name', () {
    expect(sut.name, 'coverage');
  });

  test(
    'should describe running tests with coverage and enforcing thresholds',
    () {
      expect(sut.description, contains('coverage'));
    },
  );

  test('should register the run, process and check subcommands', () {
    expect(
      sut.subcommands.keys,
      containsAll(<String>['run', 'process', 'check']),
    );
    expect(sut.subcommands['run'], isA<RunCoverageCommand>());
    expect(sut.subcommands['process'], isA<ProcessCoverageCommand>());
    expect(sut.subcommands['check'], isA<CheckCoverageCommand>());
  });
}
