import 'package:dev_tools/src/commands/coverage/check_coverage_command.dart';
import 'package:test/test.dart';

void main() {
  test('should expose the check name', () {
    expect(CheckCoverageCommand().name, 'check');
  });

  test('should describe enforcing the coverage threshold', () {
    expect(CheckCoverageCommand().description, contains('threshold'));
  });
}
