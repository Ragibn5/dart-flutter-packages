import 'package:dev_tools/src/commands/coverage/run_coverage_command.dart';
import 'package:test/test.dart';

void main() {
  test('should expose the run name', () {
    expect(RunCoverageCommand().name, 'run');
  });

  test('should describe running tests with coverage', () {
    expect(RunCoverageCommand().description, contains('coverage'));
  });
}
