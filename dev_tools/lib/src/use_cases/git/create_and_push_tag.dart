import 'dart:io';

import 'package:dev_tools/src/exceptions/command_execution_exception.dart';

class CreateAndPushTag {
  const CreateAndPushTag();

  /// Creates a lightweight tag at `HEAD` and pushes it to a remote.
  ///
  /// Params:
  /// - `tag`: the tag name to create (e.g. `foo-1.2.0`).
  /// - `repoRoot`: absolute path to the repository root to run `git` from.
  /// - `remote`: the remote to push to (default `origin`).
  ///
  /// Returns: nothing (void).
  ///
  /// Throws:
  /// - [TagCreationException] when `git tag` or `git push` fails (e.g. the
  ///   tag already exists locally, or the remote is unreachable).
  Future<void> call(
    String tag, {
    required String repoRoot,
    String remote = 'origin',
  }) async {
    final createResult = await Process.run(
      'git',
      ['tag', tag],
      workingDirectory: repoRoot,
    );
    if (createResult.exitCode != 0) {
      throw TagCreationException(
        'Error: could not create tag $tag.\n'
        '${createResult.stdout}${createResult.stderr}',
      );
    }

    final pushResult = await Process.run(
      'git',
      ['push', remote, tag],
      workingDirectory: repoRoot,
    );
    if (pushResult.exitCode != 0) {
      throw TagCreationException(
        'Error: could not push tag $tag to $remote.\n'
        '${pushResult.stdout}${pushResult.stderr}',
      );
    }
  }
}

class TagCreationException extends CommandExecutionException {
  @override
  final String message;

  const TagCreationException(this.message);
}
