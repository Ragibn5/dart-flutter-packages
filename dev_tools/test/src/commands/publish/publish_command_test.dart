import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/commands/publish/publish_command.dart';
import 'package:dev_tools/src/use_cases/git/get_repo_root_path.dart';
import 'package:dev_tools/src/use_cases/publish/run_publish_flow.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

class _MockRunPublishFlow extends Mock implements RunPublishFlow {}

class _MockGetRepoRootPath extends Mock implements GetRepoRootPath {}

void main() {
  late PublishCommand sut;

  final fakeRepoRoot = Directory.current.parent.path;

  late _MockGetRepoRootPath getRepoRootPath;

  setUp(() {
    getRepoRootPath = _MockGetRepoRootPath();
    when(() => getRepoRootPath()).thenAnswer((_) async => fakeRepoRoot);

    sut = PublishCommand(getRepoRootPath: getRepoRootPath);
  });

  test('should expose the publish name', () {
    expect(sut.name, PublishCommand.commandName);
  });

  test('should describe validating and publishing a package', () {
    expect(sut.description, PublishCommand.commandDescription);
  });

  test('should run the publish flow with the given package path', () async {
    final flow = _MockRunPublishFlow();
    when(() => flow(
          repoRoot: any(named: 'repoRoot'),
          pkgPath: any(named: 'pkgPath'),
          dryRunOnly: any(named: 'dryRunOnly'),
        )).thenAnswer((_) async {});

    await _run(
      ['--path', 'foo'],
      PublishCommand(runPublishFlow: flow, getRepoRootPath: getRepoRootPath),
    );

    verify(() => flow(
          repoRoot: fakeRepoRoot,
          pkgPath: 'foo',
        )).called(1);
  });

  test(
    'should default the package path to the relative path from the repo root',
    () async {
      final flow = _MockRunPublishFlow();
      when(() => flow(
            repoRoot: any(named: 'repoRoot'),
            pkgPath: any(named: 'pkgPath'),
            dryRunOnly: any(named: 'dryRunOnly'),
          )).thenAnswer((_) async {});

      await _run(
        [],
        PublishCommand(runPublishFlow: flow, getRepoRootPath: getRepoRootPath),
      );

      verify(() => flow(
            repoRoot: fakeRepoRoot,
            pkgPath: p.relative(Directory.current.path, from: fakeRepoRoot),
          )).called(1);
    },
  );

  test('should run the publish flow in dry-run-only mode', () async {
    final flow = _MockRunPublishFlow();
    when(() => flow(
          repoRoot: any(named: 'repoRoot'),
          pkgPath: any(named: 'pkgPath'),
          dryRunOnly: any(named: 'dryRunOnly'),
        )).thenAnswer((_) async {});

    await _run(
      ['--dry-run', '--path', 'foo'],
      PublishCommand(runPublishFlow: flow, getRepoRootPath: getRepoRootPath),
    );

    verify(() => flow(
          repoRoot: fakeRepoRoot,
          pkgPath: 'foo',
          dryRunOnly: true,
        )).called(1);
  });
}

Future<void> _run(List<String> args, PublishCommand command) async {
  final runner = CommandRunner<void>('dev_tools', '')..addCommand(command);
  await runner.run(['publish', ...args]);
}
