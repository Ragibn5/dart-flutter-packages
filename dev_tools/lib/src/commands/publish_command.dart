import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/use_cases/run_publish_flow.dart';

class PublishCommand extends Command<void> {
  final RunPublishFlow _runPublishFlow;

  PublishCommand({RunPublishFlow runPublishFlow = const RunPublishFlow()})
      : _runPublishFlow = runPublishFlow {
    argParser.addFlag(
      'dry-run',
      negatable: false,
      help: 'Only run dry-run checks, do not publish.',
    );
  }

  @override
  String get name => 'publish';

  @override
  String get description =>
      'Validate and publish a package from a release branch.';

  @override
  FutureOr<void>? run() async {
    final dryRun = argResults!.flag('dry-run');
    await _runPublishFlow(
      repoRoot: Directory.current.path,
      dryRunOnly: dryRun,
    );
  }
}
