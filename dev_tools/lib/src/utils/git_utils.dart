import 'dart:io';

import 'package:dev_tools/src/dev_tools_exception.dart';

/// Git utilities for CI change detection and release metadata.
///
/// Mirrors `git_utils.sh` and the git-related portions of `publish_utils.sh`.
class GitUtils {
  const GitUtils();

  /// Detects whether there are any changes beneath [folder] between the CI
  /// base ref and `HEAD`.
  ///
  /// When running in a GitHub Actions pull request, the base is
  /// `origin/<base-ref>`; otherwise it compares against `HEAD~1`.
  ///
  /// Throws [GitUtilityException] if the git command fails.
  Future<bool> detectFolderChanges(String folder) async {
    final isPr = Platform.environment['GITHUB_EVENT_NAME'] == 'pull_request';
    final baseRef = Platform.environment['GITHUB_BASE_REF'];
    final base = isPr && baseRef != null ? 'origin/$baseRef' : 'HEAD~1';

    final result = await Process.run('git', [
      'diff',
      '--name-only',
      '$base...HEAD',
    ]);
    if (result.exitCode != 0) {
      throw GitUtilityException(
        'Error: git diff failed.\n${result.stdout}${result.stderr}',
      );
    }
    final changed = (result.stdout as String).split('\n');
    return changed.any((line) => line.startsWith('$folder/'));
  }

  /// Returns the current branch name, or `null` when in a detached HEAD state.
  Future<String?> currentBranch([String? repoRoot]) async {
    final result = await Process.run('git', ['branch', '--show-current']);
    if (result.exitCode != 0) return null;
    final branch = (result.stdout as String).trim();
    return branch.isEmpty ? null : branch;
  }

  /// Parses a release branch name into a package path and version.
  ///
  /// Expected format: `release/<package-path>-<version>` where the package
  /// path may contain slashes. Returns `null` when the branch does not match
  /// the expected format.
  ({String packagePath, String version})? parseReleaseBranch(String branch) {
    const prefix = 'release/';
    if (!branch.startsWith(prefix)) return null;
    final rest = branch.substring(prefix.length);
    final match = RegExp(r'^(.+)-(\d+\.\d+\.\d+)$').firstMatch(rest);
    if (match == null) return null;
    return (packagePath: match.group(1)!, version: match.group(2)!);
  }

  /// Whether the working tree in [repoRoot] has uncommitted changes.
  Future<bool> hasCleanWorkingTree([String? repoRoot]) async {
    final dir = repoRoot ?? Directory.current.path;
    final result = await Process.run('git', [
      'diff',
      '--quiet',
      'HEAD',
    ], workingDirectory: dir);
    return result.exitCode == 0;
  }
}

/// Thrown when a git operation fails.
class GitUtilityException extends DevToolsException {
  const GitUtilityException(super.message);
}

/// Thrown when `detect-folder-changes` finds no changes beneath the folder.
class NoFolderChangesException extends DevToolsException {
  const NoFolderChangesException(super.message);
}
