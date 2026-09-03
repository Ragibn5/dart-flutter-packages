import 'package:dev_tools/src/commands/test_all_command.dart';
import 'package:test/test.dart';

void main() {
  test('should expose the test-all name', () {
    expect(TestAllCommand().name, 'test-all');
  });

  test('should describe discovering and running tests for all packages', () {
    expect(TestAllCommand().description, contains('test'));
  });

  test('should not take positional arguments', () {
    expect(TestAllCommand().takesArguments, isFalse);
  });
}
