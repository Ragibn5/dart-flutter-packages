import 'package:dev_tools/src/commands/coverage/run_coverage_command.dart';
import 'package:test/test.dart';

void main() {
  late RunCoverageCommand sut;

  setUp(() {
    sut = RunCoverageCommand();
  });

  test('should expose the run name', () {
    expect(sut.name, RunCoverageCommand.commandName);
  });

  test('should describe running tests with coverage', () {
    expect(sut.description, RunCoverageCommand.commandDescription);
  });
}
