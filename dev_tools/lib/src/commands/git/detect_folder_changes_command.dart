import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/use_cases/git/detect_changes_in_folder.dart';

class DetectFolderChangesCommand extends Command<void> {
  static const String commandName = 'changes';
  static const String commandDescription =
      'Detect changes in a folder (a path relative to the repository root, '
      'e.g. lib) between two refs.';

  final DetectChangesInFolder _getChangedFiles;

  DetectFolderChangesCommand({
    DetectChangesInFolder getChangedFiles = const DetectChangesInFolder(),
  }) : _getChangedFiles = getChangedFiles;

  @override
  String get name => commandName;

  @override
  String get description => commandDescription;

  @override
  FutureOr<void>? run() async {
    final rest = argResults!.rest;
    if (rest.length < 3) {
      throw UsageException(
        'Usage: dev_tools git changes <folder> <from> <to>\n'
            '  where <folder> is relative to the repository root (e.g. lib), '
            '<from> is the source ref and <to> is the target ref.',
        '',
      );
    }
    final changes = await _getChangedFiles(
      fromRef: rest[1],
      toRef: rest[2],
      folder: rest[0],
    );

    stdout
      ..write('${changes.length}')
      ..writeln();
    for (final file in changes) {
      stdout.writeln(file);
    }
  }
}

class NoFolderChangesException implements Exception {
  final String message;

  const NoFolderChangesException(this.message);
}
