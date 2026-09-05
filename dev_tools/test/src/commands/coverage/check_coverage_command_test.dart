import 'package:dev_tools/src/commands/coverage/check_coverage_command.dart';
import 'package:test/test.dart';

void main() {
  late CheckCoverageCommand sut;

  setUp(() {
    sut = CheckCoverageCommand();
  });

  test('should expose the check name', () {
    expect(sut.name, CheckCoverageCommand.commandName);
  });

  test('should describe enforcing the coverage threshold', () {
    expect(sut.description, CheckCoverageCommand.commandDescription);
  });
}
