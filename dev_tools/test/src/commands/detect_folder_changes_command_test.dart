import 'package:dev_tools/src/commands/detect_folder_changes_command.dart';
import 'package:test/test.dart';

void main() {
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
}
