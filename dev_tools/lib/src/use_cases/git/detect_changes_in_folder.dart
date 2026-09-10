import 'dart:io';

import 'package:dev_tools/src/exceptions/command_execution_exception.dart';
import 'package:path/path.dart' as p;

class DetectChangesInFolder {
  const DetectChangesInFolder();

  /// Lists the files changed between two refs, optionally scoped to a folder.
  ///
  /// Uses git's triple-dot `baseRef...compareRef` syntax: the files changed
  /// in `compareRef` since it diverged from `baseRef` (i.e. against their
  /// merge base), not a straight two-ref diff.
  ///
  /// Params:
  /// - `baseRef`: ref to diff from (branch or commit).
  /// - `compareRef`: ref to diff against (branch or commit).
  /// - `folder`: path relative to the repository root to filter changes to.
  ///   When `null`, all changed files are returned.
  ///
  /// Returns: repository-root-relative paths of the changed files.
  ///
  /// Throws:
  /// - [GitDiffingException] when `git diff` fails.
  Future<List<String>> call({
    required String baseRef,
    required String compareRef,
    String? folder,
  }) async {
    final diffResult = await Process.run(
      'git',
      ['diff', '--name-only', '$baseRef...$compareRef'],
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

    return _filterByScope(files, p.posix.normalize(folder));
  }

  List<String> _filterByScope(List<String> files, String scopeDir) {
    final scopePrefix = '$scopeDir${p.posix.separator}';
    return files.where((current) {
      final rel = p.posix.normalize(current);
      return rel == scopeDir || rel.startsWith(scopePrefix);
    }).toList();
  }
}

class GitDiffingException extends CommandExecutionException {
  @override
  final String message;

  const GitDiffingException(this.message);
}
