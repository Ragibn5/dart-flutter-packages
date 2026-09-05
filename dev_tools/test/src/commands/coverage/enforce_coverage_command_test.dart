import 'package:dev_tools/src/commands/coverage/enforce_coverage_command.dart';
import 'package:test/test.dart';

void main() {
  late EnforceCoverageCommand sut;

  setUp(() {
    sut = EnforceCoverageCommand();
  });

  test('should expose the enforce name', () {
    expect(sut.name, EnforceCoverageCommand.commandName);
  });

  test('should describe enforcing the coverage threshold', () {
    expect(sut.description, EnforceCoverageCommand.commandDescription);
  });
}
