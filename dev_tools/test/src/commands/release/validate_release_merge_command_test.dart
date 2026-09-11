import 'package:args/command_runner.dart';
import 'package:dev_tools/src/commands/release/validate_release_merge_command.dart';
import 'package:dev_tools/src/use_cases/git/get_repo_root_path.dart';
import 'package:dev_tools/src/use_cases/release/validate_release_merge.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockValidateReleaseMergeRequest extends Mock
    implements ValidateReleaseMerge {}

class _MockGetRepoRootPath extends Mock implements GetRepoRootPath {}

void main() {
  const fakeRepoRoot = '/repo';

  late _MockGetRepoRootPath getRepoRootPath;
  late _MockValidateReleaseMergeRequest validateReleaseMergeRequest;

  setUp(() {
    getRepoRootPath = _MockGetRepoRootPath();
    when(() => getRepoRootPath()).thenAnswer((_) async => fakeRepoRoot);

    validateReleaseMergeRequest = _MockValidateReleaseMergeRequest();
    when(() => validateReleaseMergeRequest(
          repoRoot: any(named: 'repoRoot'),
          fromBranch: any(named: 'fromBranch'),
          toBranch: any(named: 'toBranch'),
        )).thenAnswer((_) async {});
  });

  ValidateReleaseMergeCommand buildSut() => ValidateReleaseMergeCommand(
        getRepoRootPath: getRepoRootPath,
        validateReleaseMergeRequest: validateReleaseMergeRequest,
      );

  test('should expose the validate-release-mr name', () {
    expect(buildSut().name, ValidateReleaseMergeCommand.commandName);
  });

  test('should describe gating an MR into its target branch', () {
    expect(
      buildSut().description,
      ValidateReleaseMergeCommand.commandDescription,
    );
  });

  test('should require the --to option', () async {
    await expectLater(
      () => _run(['--from', 'feature'], buildSut()),
      throwsA(isA<ArgumentError>()),
    );

    verifyNever(() => validateReleaseMergeRequest(
          repoRoot: any(named: 'repoRoot'),
          fromBranch: any(named: 'fromBranch'),
          toBranch: any(named: 'toBranch'),
        ));
  });

  test('should default --from to HEAD', () async {
    await _run(['--to', 'origin/main'], buildSut());

    verify(() => validateReleaseMergeRequest(
          repoRoot: fakeRepoRoot,
          fromBranch: 'HEAD',
          toBranch: 'origin/main',
        )).called(1);
  });

  test('should run the merge-request gate with the given from/to branches',
      () async {
    await _run(
      ['--from', 'release/1.0.0', '--to', 'origin/main'],
      buildSut(),
    );

    verify(() => validateReleaseMergeRequest(
          repoRoot: fakeRepoRoot,
          fromBranch: 'release/1.0.0',
          toBranch: 'origin/main',
        )).called(1);
  });
}

Future<void> _run(List<String> args, ValidateReleaseMergeCommand command) {
  final runner = CommandRunner<void>('dev_tools', '')..addCommand(command);
  return runner.run([ValidateReleaseMergeCommand.commandName, ...args]);
}
