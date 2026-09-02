import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/use_cases/text_utils.dart';

class ReplaceCommand extends Command<void> {
  final TextUtils _textUtils;

  ReplaceCommand({TextUtils textUtils = const TextUtils()})
      : _textUtils = textUtils;

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
    final count = await _textUtils(
      srcText: rest[0],
      targetText: rest[1],
    );
    stdout.writeln('Replaced $count occurrence(s).');
  }
}
