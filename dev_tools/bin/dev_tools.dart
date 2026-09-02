import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/cli/commands/coverage/coverage_command.dart';
import 'package:dev_tools/src/cli/commands/dart_command.dart';
import 'package:dev_tools/src/cli/commands/flutter_command.dart';
import 'package:dev_tools/src/cli/commands/git_command.dart';
import 'package:dev_tools/src/cli/commands/publish_command.dart';
import 'package:dev_tools/src/cli/commands/replace_command.dart';
import 'package:dev_tools/src/cli/commands/test_all_command.dart';

Future<void> main(List<String> args) async {
  const executableName = 'dev_tools';
  const description = 'Shared developer tooling for Dart and Flutter projects.';
  final runner = CommandRunner<void>(executableName, description)
    ..addCommand(FlutterCommand())
    ..addCommand(DartCommand())
    ..addCommand(GitCommand())
    ..addCommand(PublishCommand())
    ..addCommand(ReplaceCommand())
    ..addCommand(TestAllCommand())
    ..addCommand(CoverageCommand());

  try {
    await runner.run(args);
  } on UsageException catch (error) {
    stderr.writeln(error.message);
    exit(1);
  }
}
