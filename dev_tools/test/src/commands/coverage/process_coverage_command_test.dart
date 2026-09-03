import 'package:dev_tools/src/commands/coverage/process_coverage_command.dart';
import 'package:test/test.dart';

void main() {
  test('should expose the process name', () {
    expect(ProcessCoverageCommand().name, 'process');
  });

  test('should describe filtering lcov data and generating an HTML report', () {
    expect(ProcessCoverageCommand().description, contains('lcov'));
  });
}
