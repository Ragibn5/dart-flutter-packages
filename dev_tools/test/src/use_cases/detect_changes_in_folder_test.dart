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

      final result = await _runGetChanged(repoDir, fromRef: base);
      expect(result.toList()..sort(),
          <String>['docs/readme.md', 'lib/a.txt']..sort());
    },
  );

  test('should filter to the folder when a folder is provided', () async {
    _commitFile(repoDir, 'base/keep.txt', 'base');
    final base = _revParse(repoDir, 'HEAD');
    _commitFile(repoDir, 'lib/a.txt', 'v1');
    _commitFile(repoDir, 'docs/readme.md', 'updated');

    final result = await _runGetChanged(repoDir, fromRef: base, folder: 'lib');
    expect(result, ['lib/a.txt']);
  });

  test('should return all changes when folder is dot', () async {
    _commitFile(repoDir, 'base/keep.txt', 'base');
    final base = _revParse(repoDir, 'HEAD');
    _commitFile(repoDir, 'lib/a.txt', 'v1');
    _commitFile(repoDir, 'docs/readme.md', 'updated');

    final result = await _runGetChanged(repoDir, fromRef: base, folder: '.');
    expect(result.toList()..sort(),
        <String>['docs/readme.md', 'lib/a.txt']..sort());
  });

  test('should return an empty list when the folder had no changes', () async {
    _commitFile(repoDir, 'base/keep.txt', 'base');
    final base = _revParse(repoDir, 'HEAD');
    _commitFile(repoDir, 'lib/a.txt', 'v1');
    _commitFile(repoDir, 'docs/readme.md', 'updated');

    final result = await _runGetChanged(repoDir, fromRef: base, folder: 'src');
    expect(result, isEmpty);
  });

  test('should honor explicit from and to refs', () async {
    _commitFile(repoDir, 'lib/a.txt', 'v1');
    final first = _revParse(repoDir, 'HEAD');
    _commitFile(repoDir, 'docs/readme.md', 'updated');

    final result = await _runGetChanged(repoDir, fromRef: first);
    expect(result, ['docs/readme.md']);
  });
}

Future<List<String>> _runGetChanged(
  Directory repoDir, {
  String fromRef = 'HEAD~1',
  String toRef = 'HEAD',
  String? folder,
}) async {
  final script = File(
    '${Directory.current.path}/test/src/use_cases/_get_changed_script.dart',
  );
  await script.writeAsString(r'''
  import 'dart:io';
  
  import 'package:dev_tools/src/use_cases/detect_changes_in_folder.dart';
  
  Future<void> main(List<String> args) async {
    final fromRef = args[0];
    final toRef = args[1];
    final folder = args.length > 2 ? args[2] : null;
    final result = await const DetectChangesInFolder()(fromRef: fromRef, toRef: toRef, folder: folder);
    stdout.writeln('RESULT=${result.join('|')}');
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
    workingDirectory: repoDir.path,
  );
  final out = await proc.stdout.transform(utf8.decoder).join();
  await proc.exitCode;
  final line = out.split('\n').firstWhere((l) => l.startsWith('RESULT='));
  final value = line.split('RESULT=')[1].trim();
  return value == '' ? <String>[] : value.split('|');
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
