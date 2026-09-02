import 'dart:io';

class DetectFolderChanges {
  const DetectFolderChanges();

  Future<bool> call(String folder) async {
    final isPr = Platform.environment['GITHUB_EVENT_NAME'] == 'pull_request';
    final baseRef = Platform.environment['GITHUB_BASE_REF'];
    final base = isPr && baseRef != null ? 'origin/$baseRef' : 'HEAD~1';
    final result = await Process.run(
      'git',
      ['diff', '--name-only', '$base...HEAD'],
    );

    if (result.exitCode != 0) {
      throw GitDiffingException(
        'Error: git diff failed.\n${result.stdout}${result.stderr}',
      );
    }

    final changed = (result.stdout as String).split('\n');
    return changed.any((line) => line.startsWith('$folder/'));
  }
}

class GitDiffingException implements Exception {
  final String message;

  const GitDiffingException(this.message);

  @override
  String toString() => message;
}
