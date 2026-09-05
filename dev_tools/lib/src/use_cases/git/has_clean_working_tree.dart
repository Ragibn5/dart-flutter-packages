import 'dart:io';

class HasCleanWorkingTree {
  const HasCleanWorkingTree();

  /// Checks whether a git repository has uncommitted changes.
  ///
  /// Params:
  /// - `repoRoot`: absolute path to the repository root
  ///   (default: the current working directory).
  ///
  /// Returns: true when the working tree is clean.
  Future<bool> call([String? repoRoot]) async {
    final dir = repoRoot ?? Directory.current.path;
    final result = await Process.run(
      'git',
      ['diff', '--quiet', 'HEAD'],
      workingDirectory: dir,
    );

    return result.exitCode == 0;
  }
}
