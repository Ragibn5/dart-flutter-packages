import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dev_tools/dev_tools.dart';

class FvmDartCommand extends Command<void> {
  final FindFvmAwareDartCommand _findFvmAwareDartCommand;

  FvmDartCommand({
    FindFvmAwareDartCommand findFvmAwareDartCommand =
        const FindFvmAwareDartCommand(),
  }) : _findFvmAwareDartCommand = findFvmAwareDartCommand;

  @override
  String get name => 'fvm-dart';

  @override
  String get description => 'returns fvm aware dart executable prefix';

  @override
  FutureOr<void>? run() async => stdout.write(await _findFvmAwareDartCommand());
}
