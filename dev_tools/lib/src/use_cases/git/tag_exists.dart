import 'dart:io';

import 'package:dev_tools/src/exceptions/command_execution_exception.dart';

class TagExists {
  const TagExists();

  /// Checks whether a tag exists on a remote.
  ///
  /// Queries the remote directly (`git ls-remote`) rather than local refs,
  /// so the result is correct even from a shallow or partial clone that
  /// hasn't fetched every tag.
  ///
  /// Params:
  /// - `tag`: the tag name to look up (e.g. `foo-v1.2.0`).
  /// - `remote`: the remote to query (default `origin`).
  /// - `repoRoot`: absolute path to the repository root to run `git` from
  ///   (default: the current working directory).
  ///
  /// Returns: true when `tag` exists on `remote`.
  ///
  /// Throws:
  /// - [TagLookupException] when `git ls-remote` fails for a reason other
  ///   than the tag not existing (e.g. the remote is unreachable or
  ///   misconfigured).
  Future<bool> call(
    String tag, {
    String remote = 'origin',
    String? repoRoot,
  }) async {
    final result = await Process.run(
      'git',
      ['ls-remote', '--exit-code', '--tags', remote, 'refs/tags/$tag'],
      workingDirectory: repoRoot ?? Directory.current.path,
    );

    if (result.exitCode == 0) {
      return true;
    }
    if (result.exitCode == 2) {
      return false;
    }

    throw TagLookupException(
      'Error: could not look up tag $tag on $remote.\n'
      '${result.stdout}${result.stderr}',
    );
  }
}

class TagLookupException extends CommandExecutionException {
  @override
  final String message;

  const TagLookupException(this.message);
}
