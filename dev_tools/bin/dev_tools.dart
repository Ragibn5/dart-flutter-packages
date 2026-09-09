import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/commands/coverage/coverage_command.dart';
import 'package:dev_tools/src/commands/dart_flutter/fvm_dart_command.dart';
import 'package:dev_tools/src/commands/dart_flutter/fvm_flutter_command.dart';
import 'package:dev_tools/src/commands/find_replace/replace_command.dart';
import 'package:dev_tools/src/commands/git/git_command.dart';
import 'package:dev_tools/src/commands/publish/publish_command.dart';
import 'package:dev_tools/src/commands/validate_merge_request_command.dart';
import 'package:dev_tools/src/exceptions/command_execution_exception.dart';

Future<void> main(List<String> args) async {
  const executableName = 'dev_tools';
  const description = 'Shared developer tooling for Dart and Flutter projects.';
  final runner = CommandRunner<dynamic>(executableName, description)
    ..addCommand(FvmDartCommand())
    ..addCommand(FvmFlutterCommand())
    ..addCommand(GitCommand())
    ..addCommand(PublishCommand())
    ..addCommand(ReplaceCommand())
    ..addCommand(CoverageCommand())
    ..addCommand(ValidateMergeRequestCommand());

  try {
    await runner.run(args);
  } on UsageException catch (e) {
    stderr.writeln(e);
    exit(1);
  } on CommandExecutionException catch (e) {
    stderr.writeln(e);
    exit(1);
  } catch (e) {
    stderr.writeln(e);
    exit(1);
  }
}
