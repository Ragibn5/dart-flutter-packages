import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/use_cases/find_replace/replace_text_in_scope.dart';

class ReplaceCommand extends Command<void> {
  static const String commandName = 'replace';
  static const String commandDescription = 'Replace literal text across files.';
  static const String startOption = 'start';
  static const String excludeOption = 'exclude';
  static const String followLinksFlag = 'follow-links';
  static const String ignoreCaseFlag = 'ignore-case';
  static const String matchWordFlag = 'match-word';
  static const String regexFlag = 'regex';
  static const String interactiveFlag = 'yes';

  final ReplaceTextInScope _replaceTextInScope;

  ReplaceCommand({ReplaceTextInScope? replaceTextInScope})
      : _replaceTextInScope = replaceTextInScope ?? ReplaceTextInScope() {
    argParser
      ..addOption(
        startOption,
        help: 'Directory to scan (default: the current directory).',
      )
      ..addMultiOption(
        excludeOption,
        abbr: 'e',
        help: 'Glob pattern to skip, relative to the start directory '
            '(e.g. lib/generated/**). Repeatable.',
      )
      ..addFlag(
        followLinksFlag,
        help: 'Follow directory symlinks while scanning.',
      )
      ..addFlag(
        ignoreCaseFlag,
        help: 'Match case-insensitively.',
      )
      ..addFlag(
        matchWordFlag,
        help: 'Only replace whole-word matches.',
      )
      ..addFlag(
        regexFlag,
        help: 'Treat <src> as a regular expression.',
      )
      ..addFlag(
        interactiveFlag,
        abbr: 'y',
        help: 'Skip the confirmation prompt and replace directly.',
      );
  }

  @override
  String get name => commandName;

  @override
  String get description => commandDescription;

  @override
  FutureOr<void>? run() async {
    final rest = argResults!.rest;
    if (rest.length < 2) {
      usageException('Missing required positional args <src> & <target>');
    }
    await _replaceTextInScope(
      srcText: rest[0],
      targetText: rest[1],
      start: argResults![startOption] as String?,
      exclusions: argResults![excludeOption] as List<String>,
      followLinks: argResults![followLinksFlag] as bool,
      ignoreCase: argResults![ignoreCaseFlag] as bool,
      matchWord: argResults![matchWordFlag] as bool,
      regex: argResults![regexFlag] as bool,
      interactive: !(argResults![interactiveFlag] as bool),
    );
  }
}
