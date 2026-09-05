import 'dart:io';
import 'package:path/path.dart' as p;

class DetectChangesInFolder {
  const DetectChangesInFolder();

  Future<List<String>> call({
    required String fromRef,
    required String toRef,
    String? folder = '.',
  }) async {
    final diffResult = await Process.run(
      'git',
      ['diff', '--name-only', '$fromRef...$toRef'],
    );

    if (diffResult.exitCode != 0) {
      throw GitDiffingException(
        'Error: git diff failed.\n'
        '${diffResult.stdout}${diffResult.stderr}',
      );
    }

    final files = (diffResult.stdout as String)
        .split('\n')
        .where((line) => line.isNotEmpty)
        .toList();
    if (folder == null) {
      return files;
    }

    final scopeDir = p.posix.normalize(folder);
    if (scopeDir == p.posix.separator || scopeDir == '.') {
      return files;
    }
    final scopePrefix = '$scopeDir${p.posix.separator}';
    return files.where((current) {
      final rel = p.posix.normalize(current);
      return rel == scopeDir || rel.startsWith(scopePrefix);
    }).toList();
  }
}

class GitDiffingException implements Exception {
  final String message;

  const GitDiffingException(this.message);

  @override
  String toString() => message;
}
