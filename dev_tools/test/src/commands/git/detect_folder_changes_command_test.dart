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

  test('should describe detecting changes against the CI base ref', () {
    expect(sut.description, DetectFolderChangesCommand.commandDescription);
  });

  test('should throw a usage exception when a required positional is missing',
      () async {
    await expectLater(
      _run(<String>[], sut),
      throwsA(isA<UsageException>()),
    );
  });

  test('should forward the folder and refs when all positionals are provided',
      () async {
    await _run(['lib', 'origin/main', 'HEAD'], sut);

    verify(() => getChangedFiles(
          fromRef: 'origin/main',
          toRef: 'HEAD',
          folder: 'lib',
        )).called(1);
  });
}

Future<void> _run(List<String> args, DetectFolderChangesCommand command) async {
  final runner = CommandRunner<void>('dev_tools', '')..addCommand(command);
  await runner.run(['changes', ...args]);
}
