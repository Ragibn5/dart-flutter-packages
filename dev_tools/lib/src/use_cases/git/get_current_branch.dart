import 'dart:io';

class GetCurrentBranch {
  const GetCurrentBranch();

  /// Reads the current branch of a git repository.
  ///
  /// Params:
  /// - `repoRoot`: absolute path to the repository root (default: the
  ///   current working directory).
  ///
  /// Returns: the current branch name, or null when in detached HEAD or
  /// outside a repository.
  Future<String?> call([String? repoRoot]) async {
    final result = await Process.run(
      'git',
      ['branch', '--show-current'],
      workingDirectory: repoRoot,
    );
    if (result.exitCode != 0) {
      return null;
    }

    final branch = (result.stdout as String).trim();
    return branch.isEmpty ? null : branch;
  }
}
