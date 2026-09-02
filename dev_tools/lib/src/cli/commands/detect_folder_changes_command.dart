import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/utils/git_utils.dart';

/// Detects whether a folder changed since the CI base ref.
class DetectFolderChangesCommand extends Command<void> {
  final GitUtils _gitUtils;

  DetectFolderChangesCommand({GitUtils gitUtils = const GitUtils()})
    : _gitUtils = gitUtils;

  @override
  String get name => 'detect-folder-changes';

  @override
  String get description =>
      'Detect whether there are changes in a folder against the CI base ref.';

  @override
  FutureOr<void>? run() async {
    final rest = argResults!.rest;
    final folder = rest.isNotEmpty ? rest[0] : null;
    if (folder == null) {
      throw UsageException(
        'Usage: dev_tools git detect-folder-changes <folder>',
        '',
      );
    }
    if (await _gitUtils.detectFolderChanges(folder)) {
      stdout.writeln('Changes detected in $folder/');
      return;
    }
    throw NoFolderChangesException('No changes in $folder/ — skipping.');
  }
}
