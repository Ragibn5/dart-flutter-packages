import 'package:dev_tools/src/commands/detect_folder_changes_command.dart';
import 'package:dev_tools/src/commands/git_command.dart';
import 'package:test/test.dart';

void main() {
  group('GitCommand', () {
    late GitCommand sut;

    setUp(() {
      sut = GitCommand();
    });

    test('should expose the git name', () {
      expect(sut.name, 'git');
    });

    test('should describe git helpers for CI change detection', () {
      expect(sut.description, contains('Git'));
    });

    test('should register the detect-folder-changes subcommand', () {
      expect(sut.subcommands, contains('detect-folder-changes'));
      expect(
        sut.subcommands['detect-folder-changes'],
        isA<DetectFolderChangesCommand>(),
      );
    });
  });

  group('DetectFolderChangesCommand', () {
    late DetectFolderChangesCommand sut;

    setUp(() {
      sut = DetectFolderChangesCommand();
    });

    test('should expose the detect-folder-changes name', () {
      expect(sut.name, 'detect-folder-changes');
    });

    test('should describe detecting changes against the CI base ref', () {
      expect(sut.description, contains('changes'));
    });
  });
}
