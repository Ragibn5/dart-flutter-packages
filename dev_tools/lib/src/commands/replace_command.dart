import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/use_cases/text_utils.dart';

class ReplaceCommand extends Command<void> {
  static const String commandName = 'replace';
  static const String commandDescription = 'Replace literal text across files.';

  final TextUtils _textUtils;

  ReplaceCommand({TextUtils? textUtils})
      : _textUtils = textUtils ?? TextUtils();

  @override
  String get name => commandName;

  @override
  String get description => commandDescription;

  @override
  FutureOr<void>? run() async {
    final rest = argResults!.rest;
    if (rest.length < 2) {
      throw UsageException('Usage: dev_tools replace <src> <target>', '');
    }
    await _textUtils(
      srcText: rest[0],
      targetText: rest[1],
    );
  }
}
