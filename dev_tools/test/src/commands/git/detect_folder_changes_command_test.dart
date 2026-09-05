import 'package:args/command_runner.dart';
import 'package:dev_tools/src/commands/git/detect_folder_changes_command.dart';
import 'package:dev_tools/src/use_cases/git/detect_changes_in_folder.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockDetectChangesInFolder extends Mock
    implements DetectChangesInFolder {}

void main() {
  late _MockDetectChangesInFolder getChangedFiles;
  late DetectFolderChangesCommand sut;

  setUp(() {
    getChangedFiles = _MockDetectChangesInFolder();
    when(() => getChangedFiles(
          fromRef: any(named: 'fromRef'),
          toRef: any(named: 'toRef'),
          folder: any(named: 'folder'),
        )).thenAnswer((_) async => <String>[]);
    sut = DetectFolderChangesCommand(getChangedFiles: getChangedFiles);
  });

  test('should expose the changes name', () {
    expect(sut.name, DetectFolderChangesCommand.commandName);
  });

  test('should describe detecting changes against HEAD~1', () {
    expect(sut.description, DetectFolderChangesCommand.commandDescription);
  });

  test('should diff HEAD~1..HEAD scoped to the folder option', () async {
    await _run(['--folder', 'lib'], sut);

    verify(() => getChangedFiles(
          fromRef: 'HEAD~1',
          toRef: 'HEAD',
          folder: 'lib',
        )).called(1);
  });

  test('should forward custom from and to refs', () async {
    await _run(['--folder', 'lib', '--from', 'main', '--to', 'dev'], sut);

    verify(() => getChangedFiles(
          fromRef: 'main',
          toRef: 'dev',
          folder: 'lib',
        )).called(1);
  });

  test('should default the folder to the whole repository', () async {
    await _run(const [], sut);

    verify(() => getChangedFiles(
          fromRef: 'HEAD~1',
          toRef: 'HEAD',
          folder: any(named: 'folder'),
        )).called(1);
  });
}

Future<void> _run(List<String> args, DetectFolderChangesCommand command) async {
  final runner = CommandRunner<void>('dev_tools', '')..addCommand(command);
  await runner.run(['changes', ...args]);
}
