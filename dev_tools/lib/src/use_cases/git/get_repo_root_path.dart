import 'dart:io';

import 'package:dev_tools/src/exceptions/command_execution_exception.dart';

class GetRepoRootPath {
  const GetRepoRootPath();

  /// Reads the root of the git repository containing [start].
  ///
  /// Params:
  /// - `start`: directory to resolve from, absolute or relative to the
  ///   current working directory (default: the current directory).
  ///
  /// Returns: the absolute path of the repository root.
  ///
  /// Throws:
  /// - [RepoRootNotFoundException] when `start` is not in a git repo.
  Future<String> call([String? start]) async {
    final result = await Process.run(
      'git',
      ['rev-parse', '--show-toplevel'],
      workingDirectory: start ?? Directory.current.path,
    );
    if (result.exitCode != 0) {
      throw RepoRootNotFoundException(
        'Error: not inside a git repository '
        '(${start ?? Directory.current.path}).',
      );
    }

    return (result.stdout as String).trim();
  }
}

class RepoRootNotFoundException extends CommandExecutionException {
  @override
  final String message;

  const RepoRootNotFoundException(this.message);
}
