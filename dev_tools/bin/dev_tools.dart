import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/commands/coverage/coverage_command.dart';
import 'package:dev_tools/src/commands/git_command.dart';
import 'package:dev_tools/src/commands/publish_command.dart';
import 'package:dev_tools/src/commands/replace_command.dart';
import 'package:dev_tools/src/commands/test_all_command.dart';

Future<void> main(List<String> args) async {
  const executableName = 'dev_tools';
  const description = 'Shared developer tooling for Dart and Flutter projects.';
  final runner = CommandRunner<void>(executableName, description)
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
