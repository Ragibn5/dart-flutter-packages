import 'package:dev_tools/src/commands/detect_folder_changes_command.dart';
import 'package:dev_tools/src/commands/git_command.dart';
import 'package:test/test.dart';

void main() {
  group('GitCommand', () {
    test('should expose the git name', () {
      expect(GitCommand().name, 'git');
    });

    test('should describe git helpers for CI change detection', () {
      expect(GitCommand().description, contains('Git'));
    });

    test('should register the detect-folder-changes subcommand', () {
      final cmd = GitCommand();
      expect(cmd.subcommands, contains('detect-folder-changes'));
      expect(
        cmd.subcommands['detect-folder-changes'],
        isA<DetectFolderChangesCommand>(),
      );
    });
  });

  group('DetectFolderChangesCommand', () {
    test('should expose the detect-folder-changes name', () {
      expect(DetectFolderChangesCommand().name, 'detect-folder-changes');
    });

    test('should describe detecting changes against the CI base ref', () {
      expect(DetectFolderChangesCommand().description, contains('changes'));
    });
  });
}
