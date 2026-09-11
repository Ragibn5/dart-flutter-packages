import 'package:dev_tools/src/commands/coverage/generate_coverage_report_command.dart';
import 'package:test/test.dart';

void main() {
  late GenerateCoverageReportCommand sut;

  setUp(() {
    sut = GenerateCoverageReportCommand();
  });

  test('should expose the genreport name', () {
    expect(sut.name, GenerateCoverageReportCommand.commandName);
  });

  test('should describe generating an HTML coverage report', () {
    expect(sut.description, GenerateCoverageReportCommand.commandDescription);
  });
}
