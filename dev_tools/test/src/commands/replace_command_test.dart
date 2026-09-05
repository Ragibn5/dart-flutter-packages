import 'package:dev_tools/src/commands/replace_command.dart';
import 'package:test/test.dart';

void main() {
  late ReplaceCommand sut;

  setUp(() {
    sut = ReplaceCommand();
  });

  test('should expose the replace name', () {
    expect(sut.name, ReplaceCommand.commandName);
  });

  test('should describe replacing literal text across files', () {
    expect(sut.description, ReplaceCommand.commandDescription);
  });
}
