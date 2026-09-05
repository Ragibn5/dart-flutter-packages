import 'package:dev_tools/src/commands/detect_folder_changes_command.dart';
import 'package:dev_tools/src/commands/git/git_command.dart';
import 'package:test/test.dart';

void main() {
  late GitCommand sut;

  setUp(() {
    sut = GitCommand();
  });

  test('should expose the git name', () {
    expect(sut.name, GitCommand.commandName);
  });

  test('should describe git helpers for CI change detection', () {
    expect(sut.description, GitCommand.commandDescription);
  });

  test('should register the changes subcommand', () {
    expect(sut.subcommands, contains(DetectFolderChangesCommand.commandName));
    expect(
      sut.subcommands[DetectFolderChangesCommand.commandName],
      isA<DetectFolderChangesCommand>(),
    );
  });
}
