import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  late Directory scriptDir;
  late Directory repoDir;

  setUp(() {
    scriptDir = Directory.systemTemp.createTempSync('detect_script');
    repoDir = Directory.systemTemp.createTempSync('detect_repo');
    _runGit(repoDir, ['init', '-q']);
    _runGit(repoDir, ['config', 'user.email', 'test@example.com']);
    _runGit(repoDir, ['config', 'user.name', 'Test']);
  });

  tearDown(() {
    for (final dir in [scriptDir, repoDir]) {
      if (dir.existsSync()) dir.deleteSync(recursive: true);
    }
  });

  test(
    'should return true when the folder changed in the latest commit vs HEAD~1',
    () async {
      _commitFile(repoDir, 'lib/a.txt', 'v1');
      _commitFile(repoDir, 'lib/a.txt', 'v2');

      final result = await _runDetect(repoDir, 'lib');
      expect(result, isTrue);
    },
  );

  test(
    'should return false when the folder did not change in the latest commit',
    () async {
      _commitFile(repoDir, 'lib/a.txt', 'v1');
      _commitFile(repoDir, 'docs/readme.md', 'updated');

      final result = await _runDetect(repoDir, 'lib');
      expect(result, isFalse);
    },
  );
}

Future<bool> _runDetect(Directory repoDir, String folder) async {
  final script = File(
    '${Directory.current.path}/test/src/use_cases/_detect_script.dart',
  );
  // Place the script inside the package so package:dev_tools resolves.
  script.writeAsString('''
import 'dart:io';

import 'package:dev_tools/src/use_cases/detect_folder_changes.dart';

Future<void> main(List<String> args) async {
  final result = await const DetectFolderChanges()(args[0]);
  stdout.writeln('RESULT=\$result');
}
''');
  addTearDown(() {
    if (script.existsSync()) script.deleteSync();
  });

  final proc = await Process.start('dart', [
    'run',
    script.path,
    folder,
  ], workingDirectory: repoDir.path);
  final out = await proc.stdout.transform(utf8.decoder).join();
  await proc.exitCode;
  return out
          .split('\n')
          .firstWhere((line) => line.contains('RESULT='))
          .split('RESULT=')[1]
          .trim() ==
      'true';
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
