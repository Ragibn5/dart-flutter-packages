import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/use_cases/git/detect_changes_in_folder.dart';

class DetectFolderChangesCommand extends Command<void> {
  static const String commandName = 'changes';
  static const String commandDescription =
      'Detect changes in a folder (default: the whole repository) between '
      'two refs (defaults: HEAD and HEAD~1).';
  static const String fromOption = 'from';
  static const String toOption = 'to';
  static const String folderOption = 'folder';

  final DetectChangesInFolder _getChangedFiles;

  DetectFolderChangesCommand({
    DetectChangesInFolder getChangedFiles = const DetectChangesInFolder(),
  }) : _getChangedFiles = getChangedFiles {
    argParser
      ..addOption(
        fromOption,
        defaultsTo: 'HEAD~1',
        help: 'Source ref to diff from.',
      )
      ..addOption(
        toOption,
        defaultsTo: 'HEAD',
        help: 'Target ref to diff against.',
      )
      ..addOption(
        folderOption,
        help: 'Folder to detect changes in, relative to the repository root '
            '(default: the repo root).',
      );
  }

  @override
  String get name => commandName;

  @override
  String get description => commandDescription;

  @override
  FutureOr<void>? run() async {
    final changes = await _getChangedFiles(
      fromRef: argResults![fromOption] as String,
      toRef: argResults![toOption] as String,
      folder: argResults![folderOption] as String?,
    );

    stdout
      ..write('${changes.length}')
      ..writeln();
    for (final file in changes) {
      stdout.writeln(file);
    }
  }
}
