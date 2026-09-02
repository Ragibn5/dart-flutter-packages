import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/use_cases/detect_folder_changes.dart';

class DetectFolderChangesCommand extends Command<void> {
  final DetectFolderChanges _detectFolderChanges;

  DetectFolderChangesCommand({
    DetectFolderChanges detectFolderChanges = const DetectFolderChanges(),
  }) : _detectFolderChanges = detectFolderChanges;

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
    if (await _detectFolderChanges(folder)) {
      stdout.writeln('Changes detected in $folder/');
      return;
    }
    throw NoFolderChangesException('No changes in $folder/ — skipping.');
  }
}

class NoFolderChangesException implements Exception {
  final String message;

  const NoFolderChangesException(this.message);
}
