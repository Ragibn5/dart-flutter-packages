import 'package:dev_tools/src/commands/coverage/generate_coverage_report_command.dart';
import 'package:test/test.dart';

void main() {
  late GenerateCoverageReportCommand sut;

  setUp(() {
    sut = GenerateCoverageReportCommand();
  });

  test('should expose the generate-coverage-report name', () {
    expect(sut.name, 'generate-coverage-report');
  });

  test('should describe generating an HTML coverage report', () {
    expect(sut.description, contains('HTML'));
  });
}
