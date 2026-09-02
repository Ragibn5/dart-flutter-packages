import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/utils/publish_utils.dart';

/// Validates and publishes a package from a release branch.
class PublishCommand extends Command<void> {
  final PublishUtils _publishUtils;

  PublishCommand({PublishUtils publishUtils = const PublishUtils()})
    : _publishUtils = publishUtils {
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
    await _publishUtils.runPublishFlow(
      repoRoot: Directory.current.path,
      dryRunOnly: dryRun,
    );
  }
}
