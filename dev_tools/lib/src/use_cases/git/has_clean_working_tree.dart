import 'dart:io';

class HasCleanWorkingTree {
  const HasCleanWorkingTree();

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
