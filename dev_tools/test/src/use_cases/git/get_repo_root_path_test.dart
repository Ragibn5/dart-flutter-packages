import 'dart:io';

import 'package:dev_tools/src/use_cases/git/get_repo_root_path.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  late Directory repoDir;
  late Directory nestedDir;

  late GetRepoRootPath sut;

  String resolved(String path) => Directory(path).resolveSymbolicLinksSync();

  void runGit(Directory dir, List<String> args) {
    final result = Process.runSync('git', args, workingDirectory: dir.path);
    if (result.exitCode != 0) {
      throw StateError('git ${args.join(' ')} failed: ${result.stderr}');
    }
  }

  setUp(() {
    repoDir = Directory.systemTemp.createTempSync('get_repo_root_path_test');
    runGit(repoDir, ['init', '-q']);
    nestedDir = Directory('${repoDir.path}/packages/foo')
      ..createSync(recursive: true);

    sut = const GetRepoRootPath();
  });

  tearDown(() {
    if (repoDir.existsSync()) repoDir.deleteSync(recursive: true);
  });

  group('absolute start path', () {
    test('resolves from the repo root itself', () async {
      expect(await sut(repoDir.path), resolved(repoDir.path));
    });

    test('resolves from a nested subdirectory', () async {
      expect(await sut(nestedDir.path), resolved(repoDir.path));
    });

    test('resolves with a trailing slash', () async {
      expect(await sut('${nestedDir.path}/'), resolved(repoDir.path));
    });

    test('resolves through a non-normalized ".." segment', () async {
      final withDotDot = '${nestedDir.path}/../foo';
      expect(await sut(withDotDot), resolved(repoDir.path));
    });
  });

  group('relative start path (relative to Directory.current)', () {
    late String originalCwd;

    setUp(() => originalCwd = Directory.current.path);
    tearDown(() => Directory.current = originalCwd);

    test('resolves "." when cwd is the repo root', () async {
      Directory.current = repoDir.path;
      expect(await sut('.'), resolved(repoDir.path));
    });

    test('resolves a relative subpath computed from an unrelated cwd',
        () async {
      // cwd is unrelated to the repo; the relative path is resolved
      // against *this* cwd, per Process.run semantics, then git walks up
      // from there to find the repo.
      final relative = p.relative(nestedDir.path, from: Directory.current.path);
      expect(await sut(relative), resolved(repoDir.path));
    });

    test('resolves "packages/foo" when cwd is the repo root', () async {
      Directory.current = repoDir.path;
      expect(await sut('packages/foo'), resolved(repoDir.path));
    });

    test('resolves ".." from a nested subdirectory', () async {
      Directory.current = nestedDir.path;
      expect(await sut('..'), resolved(repoDir.path));
    });
  });

  group('null start path (defaults to Directory.current)', () {
    late String originalCwd;

    setUp(() => originalCwd = Directory.current.path);
    tearDown(() => Directory.current = originalCwd);

    test('resolves using the current working directory when cwd is nested',
        () async {
      Directory.current = nestedDir.path;
      expect(await sut(), resolved(repoDir.path));
    });
  });

  test(
    'should throw RepoRootNotFoundException when not inside a git repository',
    () async {
      final outside = Directory.systemTemp.createTempSync('not_a_repo_test');
      addTearDown(() {
        if (outside.existsSync()) outside.deleteSync(recursive: true);
      });

      await expectLater(
        sut(outside.path),
        throwsA(isA<RepoRootNotFoundException>()),
      );
    },
  );

  test(
    'throws ProcessException (not RepoRootNotFoundException) when start '
    "doesn't exist at all",
    () async {
      await expectLater(
        sut('${repoDir.path}/does/not/exist'),
        throwsA(isA<ProcessException>()),
      );
    },
  );
}
