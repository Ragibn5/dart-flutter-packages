import 'package:dev_tools/src/commands/replace_command.dart';
import 'package:test/test.dart';

void main() {
  test('should expose the replace name', () {
    expect(ReplaceCommand().name, 'replace');
  });

  test('should describe replacing literal text across files', () {
    expect(ReplaceCommand().description, contains('Replace'));
  });
}
