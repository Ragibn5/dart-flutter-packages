import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/use_cases/publish/run_publish_flow.dart';

class PublishCommand extends Command<void> {
  static const String commandName = 'publish';
  static const String commandDescription = 'Validate and publish a package.';
  static const String pathOption = 'path';

  final RunPublishFlow _runPublishFlow;

  PublishCommand({RunPublishFlow runPublishFlow = const RunPublishFlow()})
      : _runPublishFlow = runPublishFlow {
    argParser
      ..addFlag(
        'dry-run',
        negatable: false,
        help: 'Only run dry-run checks, do not publish.',
      )
      ..addOption(
        pathOption,
        abbr: 'p',
        mandatory: true,
        help: 'Package directory relative to the repository root.',
      );
  }

  @override
  String get name => commandName;

  @override
  String get description => commandDescription;

  @override
  FutureOr<void>? run() async {
    final dryRun = argResults!.flag('dry-run');
    final pkgPath = argResults![pathOption] as String;
    await _runPublishFlow(
      repoRoot: Directory.current.path,
      pkgPath: pkgPath,
      dryRunOnly: dryRun,
    );
  }
}
