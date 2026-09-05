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
  }) : _getChangedFiles = getChangedFiles {
    argParser
      ..addOption(
        'from',
        mandatory: true,
        help: 'The source ref to diff from (branch or commit).',
      )
      ..addOption(
        'to',
        mandatory: true,
        help: 'The target ref to diff against (branch or commit).',
      );
  }

  @override
  String get name => commandName;

  @override
  String get description => commandDescription;

  @override
  FutureOr<void>? run() async {
    final rest = argResults!.rest;
    final folder = rest.isNotEmpty ? rest[0] : null;
    if (folder == null) {
      throw UsageException(
        'Usage: dev_tools git changes <folder> '
            '--from <ref> --to <ref>\n'
            '  where <folder> is relative to the repository root (e.g. lib).',
        '',
      );
    }
    final changes = await _getChangedFiles(
      fromRef: argResults!['from'] as String,
      toRef: argResults!['to'] as String,
      folder: folder,
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
