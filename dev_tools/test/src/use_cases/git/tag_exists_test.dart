import 'dart:io';

import 'package:dev_tools/src/use_cases/git/tag_exists.dart';
import 'package:test/test.dart';

void main() {
  late Directory bareRemoteDir;
  late Directory cloneDir;

  const sut = TagExists();

  setUp(() {
    bareRemoteDir = Directory.systemTemp.createTempSync('tag_exists_remote');
    _runGit(bareRemoteDir, ['init', '-q', '--bare']);

    cloneDir = Directory.systemTemp.createTempSync('tag_exists_clone');
    _runGit(cloneDir, ['init', '-q']);
    _runGit(cloneDir, ['config', 'user.email', 'test@example.com']);
    _runGit(cloneDir, ['config', 'user.name', 'Test']);
    _runGit(cloneDir, ['remote', 'add', 'origin', bareRemoteDir.path]);
    _commitFile(cloneDir, 'file.txt', 'v1');
    _runGit(cloneDir, ['push', '-q', 'origin', 'HEAD:refs/heads/main']);
  });

  tearDown(() {
    if (bareRemoteDir.existsSync()) bareRemoteDir.deleteSync(recursive: true);
    if (cloneDir.existsSync()) cloneDir.deleteSync(recursive: true);
  });

  test('should return true when the tag exists on the remote', () async {
    _runGit(cloneDir, ['tag', 'pkg-v1.0.0']);
    _runGit(cloneDir, ['push', '-q', 'origin', 'pkg-v1.0.0']);

    final exists = await sut('pkg-v1.0.0', repoRoot: cloneDir.path);

    expect(exists, isTrue);
  });

  test('should return false when the tag does not exist on the remote',
      () async {
    final exists = await sut('pkg-v9.9.9', repoRoot: cloneDir.path);

    expect(exists, isFalse);
  });

  test(
      'should return false for a local-only tag that was never pushed to '
      'the remote', () async {
    _runGit(cloneDir, ['tag', 'pkg-v2.0.0']);

    final exists = await sut('pkg-v2.0.0', repoRoot: cloneDir.path);

    expect(exists, isFalse);
  });

  test('should throw TagLookupException when the remote cannot be reached',
      () async {
    await expectLater(
      sut('pkg-v1.0.0', remote: 'no-such-remote', repoRoot: cloneDir.path),
      throwsA(isA<TagLookupException>()),
    );
  });
}

void _commitFile(Directory repoDir, String relPath, String content) {
  final file = File('${repoDir.path}/$relPath')
    ..createSync(recursive: true)
    ..writeAsStringSync(content);
  _runGit(repoDir, ['add', file.path]);
  _runGit(repoDir, ['commit', '-q', '-m', relPath]);
}

void _runGit(Directory dir, List<String> args) {
  final result = Process.runSync('git', args, workingDirectory: dir.path);
  if (result.exitCode != 0) {
    throw StateError('git ${args.join(' ')} failed: ${result.stderr}');
  }
}
