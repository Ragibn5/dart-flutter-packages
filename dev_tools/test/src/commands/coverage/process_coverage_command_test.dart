import 'package:dev_tools/src/commands/coverage/process_coverage_command.dart';
import 'package:test/test.dart';

void main() {
  late ProcessCoverageCommand sut;

  setUp(() {
    sut = ProcessCoverageCommand();
  });

  test('should expose the process-coverage name', () {
    expect(sut.name, 'process-coverage');
  });

  test('should describe filtering lcov data using exclusion patterns', () {
    expect(sut.description, contains('lcov'));
  });
}
