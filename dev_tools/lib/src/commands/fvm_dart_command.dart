import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dev_tools/dev_tools.dart';

class FvmDartCommand extends Command<void> {
  static const String commandName = 'fvm-dart';
  static const String commandDescription =
      'returns fvm aware dart executable prefix';

  final FindFvmAwareDartCommand _findFvmAwareDartCommand;

  FvmDartCommand({
    FindFvmAwareDartCommand findFvmAwareDartCommand =
        const FindFvmAwareDartCommand(),
  }) : _findFvmAwareDartCommand = findFvmAwareDartCommand;

  @override
  String get name => commandName;

  @override
  String get description => commandDescription;

  @override
  FutureOr<void>? run() async => stdout.write(await _findFvmAwareDartCommand());
}
