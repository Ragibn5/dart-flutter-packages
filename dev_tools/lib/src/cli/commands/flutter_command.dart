import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/utils/flutter_command_finder.dart';

class FlutterCommand extends Command<void> {
  final FlutterCommandFinder _findFlutterCommand;

  FlutterCommand({
    FlutterCommandFinder flutterCommandFinder = const FlutterCommandFinder(),
  }) : _findFlutterCommand = flutterCommandFinder;

  @override
  String get name => 'flutter';

  @override
  String get description =>
      'Resolve the Flutter command and print it to stdout (honors fvm).';

  @override
  FutureOr<void>? run() async => stdout.writeln(await _findFlutterCommand());
}
