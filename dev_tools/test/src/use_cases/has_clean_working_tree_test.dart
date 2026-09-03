import 'dart:io';

import 'package:dev_tools/src/use_cases/has_clean_working_tree.dart';
import 'package:test/test.dart';

void main() {
  late Directory repoDir;

  late HasCleanWorkingTree sut;

  setUp(() {
    repoDir = Directory.systemTemp.createTempSync('clean_tree_test');
    _runGit(repoDir, ['init', '-q']);
    _runGit(repoDir, ['config', 'user.email', 'test@example.com']);
    _runGit(repoDir, ['config', 'user.name', 'Test']);

    sut = const HasCleanWorkingTree();
  });

  tearDown(() {
    if (repoDir.existsSync()) repoDir.deleteSync(recursive: true);
  });

  test('should return true when working tree has no changes', () async {
    File('${repoDir.path}/a.txt').writeAsStringSync('content\n');
    _runGit(repoDir, ['add', '.']);
    _runGit(repoDir, ['commit', '-q', '-m', 'init']);

    expect(await sut(repoDir.path), isTrue);
  });

  test(
    'should return false when working tree has uncommitted changes',
    () async {
      File('${repoDir.path}/a.txt').writeAsStringSync('content\n');
      _runGit(repoDir, ['add', '.']);
      _runGit(repoDir, ['commit', '-q', '-m', 'init']);
      File('${repoDir.path}/a.txt').writeAsStringSync('modified\n');

      expect(await sut(repoDir.path), isFalse);
    },
  );
}

void _runGit(Directory dir, List<String> args) {
  final result = Process.runSync('git', args, workingDirectory: dir.path);
  if (result.exitCode != 0) {
    throw StateError('git ${args.join(' ')} failed: ${result.stderr}');
  }
}
