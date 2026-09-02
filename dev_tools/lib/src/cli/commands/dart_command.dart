import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/utils/dart_command_finder.dart';

/// Prints the command used to invoke Dart (honoring fvm).
class DartCommand extends Command<void> {
  final DartCommandFinder _findDartCommand;

  DartCommand({DartCommandFinder dartCommandFinder = const DartCommandFinder()})
    : _findDartCommand = dartCommandFinder;

  @override
  String get name => 'dart';

  @override
  String get description =>
      'Resolve the Dart command and print it to stdout (honors fvm).';

  @override
  FutureOr<void>? run() async => stdout.writeln(await _findDartCommand());
}
