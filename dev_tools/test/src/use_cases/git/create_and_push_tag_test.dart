import 'dart:io';

import 'package:dev_tools/src/use_cases/git/create_and_push_tag.dart';
import 'package:test/test.dart';

void main() {
  late Directory bareRemoteDir;
  late Directory cloneDir;

  const sut = CreateAndPushTag();

  setUp(() {
    bareRemoteDir =
        Directory.systemTemp.createTempSync('create_and_push_tag_remote');
    _runGit(bareRemoteDir, ['init', '-q', '--bare']);

    cloneDir = Directory.systemTemp.createTempSync('create_and_push_tag_clone');
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

  test('should create the tag locally and push it to the remote', () async {
    await sut('pkg-v1.0.0', repoRoot: cloneDir.path);

    expect(_tagExistsLocally(cloneDir, 'pkg-v1.0.0'), isTrue);
    expect(_tagExistsOnRemote(bareRemoteDir, 'pkg-v1.0.0'), isTrue);
  });

  test(
      'should throw TagCreationException when the tag already exists '
      'locally', () async {
    _runGit(cloneDir, ['tag', 'pkg-v1.0.0']);

    await expectLater(
      sut('pkg-v1.0.0', repoRoot: cloneDir.path),
      throwsA(isA<TagCreationException>()),
    );
  });

  test('should throw TagCreationException when the remote cannot be reached',
      () async {
    await expectLater(
      sut('pkg-v1.0.0', remote: 'no-such-remote', repoRoot: cloneDir.path),
      throwsA(isA<TagCreationException>()),
    );

    // The tag is still created locally even though the push failed.
    expect(_tagExistsLocally(cloneDir, 'pkg-v1.0.0'), isTrue);
  });
}

bool _tagExistsLocally(Directory repoDir, String tag) {
  final result = Process.runSync(
    'git',
    ['tag', '--list', tag],
    workingDirectory: repoDir.path,
  );
  return (result.stdout as String).trim() == tag;
}

bool _tagExistsOnRemote(Directory bareRemoteDir, String tag) {
  final result = Process.runSync(
    'git',
    ['tag', '--list', tag],
    workingDirectory: bareRemoteDir.path,
  );
  return (result.stdout as String).trim() == tag;
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
