import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/use_cases/find_fvm_aware_flutter_command.dart';

class FvmFlutterCommand extends Command<void> {
  static const String commandName = 'fvm-flutter';
  static const String commandDescription =
      'returns fvm aware flutter executable prefix';

  final FindFvmAwareFlutterCommand _findFvmAwareFlutterCommand;

  FvmFlutterCommand({
    FindFvmAwareFlutterCommand findFvmAwareFlutterCommand =
        const FindFvmAwareFlutterCommand(),
  }) : _findFvmAwareFlutterCommand = findFvmAwareFlutterCommand;

  @override
  String get name => commandName;

  @override
  String get description => commandDescription;

  @override
  FutureOr<void>? run() async =>
      stdout.write(await _findFvmAwareFlutterCommand());
}
