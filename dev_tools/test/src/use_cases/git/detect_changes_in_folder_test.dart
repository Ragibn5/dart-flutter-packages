import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  late Directory repoDir;

  setUp(() {
    repoDir = Directory.systemTemp.createTempSync('changed_files_repo');
    _runGit(repoDir, ['init', '-q']);
    _runGit(repoDir, ['config', 'user.email', 'test@example.com']);
    _runGit(repoDir, ['config', 'user.name', 'Test']);
  });

  tearDown(() {
    if (repoDir.existsSync()) repoDir.deleteSync(recursive: true);
  });

  test(
    'should return all changed files between two refs without a folder filter',
    () async {
      _commitFile(repoDir, 'base/keep.txt', 'base');
      final base = _revParse(repoDir, 'HEAD');
      _commitFile(repoDir, 'lib/a.txt', 'v1');
      _commitFile(repoDir, 'docs/readme.md', 'updated');

      final result = _parseResult(await _runGetChanged(repoDir, fromRef: base));
      expect(result.toList()..sort(),
          <String>['docs/readme.md', 'lib/a.txt']..sort());
    },
  );

  test('should filter to the folder when a folder is provided', () async {
    _commitFile(repoDir, 'base/keep.txt', 'base');
    final base = _revParse(repoDir, 'HEAD');
    _commitFile(repoDir, 'lib/a.txt', 'v1');
    _commitFile(repoDir, 'docs/readme.md', 'updated');

    final result = _parseResult(
        await _runGetChanged(repoDir, fromRef: base, folder: 'lib'));
    expect(result, ['lib/a.txt']);
  });

  test('should return all changes when no folder is provided (repo root)',
      () async {
    _commitFile(repoDir, 'base/keep.txt', 'base');
    final base = _revParse(repoDir, 'HEAD');
    _commitFile(repoDir, 'lib/a.txt', 'v1');
    _commitFile(repoDir, 'docs/readme.md', 'updated');

    final result = _parseResult(await _runGetChanged(repoDir, fromRef: base));
    expect(result.toList()..sort(),
        <String>['docs/readme.md', 'lib/a.txt']..sort());
  });

  test(
      'should return an empty list for a folder that cannot match '
      'repository-root-relative paths', () async {
    _commitFile(repoDir, 'base/keep.txt', 'base');
    final base = _revParse(repoDir, 'HEAD');
    _commitFile(repoDir, 'lib/a.txt', 'v1');
    _commitFile(repoDir, 'docs/readme.md', 'updated');

    for (final folder in const <String>['.', '..', '../..', '/']) {
      final result = _parseResult(
          await _runGetChanged(repoDir, fromRef: base, folder: folder));
      expect(result, isEmpty, reason: 'folder: "$folder"');
    }
  });

  test(
      'should return an empty list when folder escapes the repository root '
      'and run from a subfolder', () async {
    _commitFile(repoDir, 'base/keep.txt', 'base');
    final base = _revParse(repoDir, 'HEAD');
    _commitFile(repoDir, 'lib/a.txt', 'v1');
    _commitFile(repoDir, 'docs/readme.md', 'updated');

    final result = _parseResult(await _runGetChanged(
      repoDir,
      fromRef: base,
      folder: '..',
      cwd: '${repoDir.path}/lib',
    ));
    expect(result, isEmpty);
  });

  test('should return an empty list when the folder had no changes', () async {
    _commitFile(repoDir, 'base/keep.txt', 'base');
    final base = _revParse(repoDir, 'HEAD');
    _commitFile(repoDir, 'lib/a.txt', 'v1');
    _commitFile(repoDir, 'docs/readme.md', 'updated');

    final result = _parseResult(
        await _runGetChanged(repoDir, fromRef: base, folder: 'src'));
    expect(result, isEmpty);
  });

  test('should return all changed files when run from a subfolder', () async {
    _commitFile(repoDir, 'base/keep.txt', 'base');
    final base = _revParse(repoDir, 'HEAD');
    _commitFile(repoDir, 'lib/a.txt', 'v1');
    _commitFile(repoDir, 'docs/readme.md', 'updated');

    final result = _parseResult(await _runGetChanged(
      repoDir,
      fromRef: base,
      cwd: '${repoDir.path}/lib',
    ));
    expect(result.toList()..sort(),
        <String>['docs/readme.md', 'lib/a.txt']..sort());
  });

  test(
      'should keep explicit folders repository-root-relative from a '
      'subfolder', () async {
    _commitFile(repoDir, 'base/keep.txt', 'base');
    final base = _revParse(repoDir, 'HEAD');
    _commitFile(repoDir, 'lib/a.txt', 'v1');
    _commitFile(repoDir, 'docs/readme.md', 'updated');

    final result = _parseResult(await _runGetChanged(
      repoDir,
      fromRef: base,
      folder: 'lib',
      cwd: '${repoDir.path}/docs',
    ));
    expect(result, ['lib/a.txt']);
  });

  test('should honor explicit from and to refs', () async {
    _commitFile(repoDir, 'lib/a.txt', 'v1');
    final first = _revParse(repoDir, 'HEAD');
    _commitFile(repoDir, 'docs/readme.md', 'updated');

    final result = _parseResult(await _runGetChanged(repoDir, fromRef: first));
    expect(result, ['docs/readme.md']);
  });

  test('should throw GitDiffingException when git fails', () async {
    final nonRepo = Directory.systemTemp.createTempSync('not_a_repo');
    addTearDown(() {
      if (nonRepo.existsSync()) nonRepo.deleteSync(recursive: true);
    });

    final error = _parseError(await _runGetChanged(nonRepo,
        fromRef: 'HEAD~1')); // ignore: avoid_redundant_argument_values

    expect(error, startsWith('Error: git diff failed.'));
  });
}

Future<String> _runGetChanged(
  Directory repoDir, {
  String fromRef = 'HEAD~1',
  String toRef = 'HEAD',
  String? folder,
  String? cwd,
}) async {
  final script = File(
    '${Directory.current.path}/test/src/use_cases/git/_get_changed_script.dart',
  );
  await script.writeAsString(r'''
  import 'dart:io';
  
  import 'package:dev_tools/src/use_cases/git/detect_changes_in_folder.dart';
  
  Future<void> main(List<String> args) async {
    final fromRef = args[0];
    final toRef = args[1];
    final folder = args.length > 2 ? args[2] : null;
    try {
      final result = await const DetectChangesInFolder()(fromRef: fromRef, toRef: toRef, folder: folder);
      stdout.writeln('RESULT=${result.join('|')}');
    } on GitDiffingException catch (error) {
      stdout.writeln('ERROR=${error.message}');
    }
  }
  ''');
  addTearDown(() {
    if (script.existsSync()) script.deleteSync();
  });

  final args = <String>[fromRef, toRef];
  if (folder != null) args.add(folder);
  final proc = await Process.start(
    'dart',
    ['run', script.path, ...args],
    workingDirectory: cwd ?? repoDir.path,
  );
  final out = await proc.stdout.transform(utf8.decoder).join();
  await proc.exitCode;
  return out;
}

List<String> _parseResult(String out) {
  final line = out.split('\n').firstWhere((l) => l.startsWith('RESULT='));
  final value = line.split('RESULT=')[1].trim();
  return value.isEmpty ? <String>[] : value.split('|');
}

String _parseError(String out) {
  final line = out.split('\n').firstWhere((l) => l.startsWith('ERROR='));
  return line.split('ERROR=')[1].trim();
}

String _revParse(Directory repoDir, String ref) {
  final result = Process.runSync(
    'git',
    ['rev-parse', ref],
    workingDirectory: repoDir.path,
  );
  if (result.exitCode != 0) {
    throw StateError('git rev-parse $ref failed: ${result.stderr}');
  }
  return (result.stdout as String).trim();
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
