import 'package:dev_tools/src/commands/test_all_command.dart';
import 'package:test/test.dart';

void main() {
  late TestAllCommand sut;

  setUp(() {
    sut = TestAllCommand();
  });

  test('should expose the test-all name', () {
    expect(sut.name, TestAllCommand.commandName);
  });

  test('should describe discovering and running tests for all packages', () {
    expect(sut.description, TestAllCommand.commandDescription);
  });

  test('should not take positional arguments', () {
    expect(sut.takesArguments, isFalse);
  });
}
