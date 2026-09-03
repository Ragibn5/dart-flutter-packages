import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/use_cases/find_fvm_aware_flutter_command.dart';

class FvmFlutterCommand extends Command<void> {
  final FindFvmAwareFlutterCommand _findFvmAwareFlutterCommand;

  FvmFlutterCommand({
    FindFvmAwareFlutterCommand findFvmAwareFlutterCommand =
        const FindFvmAwareFlutterCommand(),
  }) : _findFvmAwareFlutterCommand = findFvmAwareFlutterCommand;

  @override
  String get name => 'fvm-flutter';

  @override
  String get description => 'returns fvm aware flutter executable prefix';

  @override
  FutureOr<void>? run() async =>
      stdout.write(await _findFvmAwareFlutterCommand());
}
