import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/use_cases/text_utils.dart';

class ReplaceCommand extends Command<void> {
  final TextUtils _textUtils;

  ReplaceCommand({TextUtils? textUtils})
    : _textUtils = textUtils ?? TextUtils();

  @override
  String get name => 'replace';

  @override
  String get description => 'Replace literal text across files.';

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
