import 'package:dev_tools/src/commands/coverage/process_coverage_command.dart';
import 'package:test/test.dart';

void main() {
  late ProcessCoverageCommand sut;

  setUp(() {
    sut = ProcessCoverageCommand();
  });

  test('should expose the process name', () {
    expect(sut.name, 'process');
  });

  test('should describe filtering lcov data and generating an HTML report', () {
    expect(sut.description, contains('lcov'));
  });
}
