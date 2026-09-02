import 'dart:io';

class GetCurrentBranch {
  const GetCurrentBranch();

  Future<String?> call([String? repoRoot]) async {
    final result = await Process.run('git', ['branch', '--show-current']);
    if (result.exitCode != 0) {
      return null;
    }

    final branch = (result.stdout as String).trim();
    return branch.isEmpty ? null : branch;
  }
}
