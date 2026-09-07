import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/use_cases/git/get_repo_root_path.dart';
import 'package:dev_tools/src/use_cases/publish/run_publish_flow.dart';
import 'package:path/path.dart' as p;

class PublishCommand extends Command<void> {
  static const String commandName = 'publish';
  static const String commandDescription = 'Validate and publish a package.';
  static const String pathOption = 'path';

  final RunPublishFlow _runPublishFlow;
  final GetRepoRootPath _getRepoRootPath;

  PublishCommand({
    GetRepoRootPath getRepoRootPath = const GetRepoRootPath(),
    RunPublishFlow runPublishFlow = const RunPublishFlow(),
  })  : _getRepoRootPath = getRepoRootPath,
        _runPublishFlow = runPublishFlow {
    argParser
      ..addFlag(
        'dry-run',
        negatable: false,
        help: 'Only run dry-run checks, do not publish.',
      )
      ..addOption(
        pathOption,
        abbr: 'p',
        help: 'Package directory relative to the repository root.'
            '\n(Defaults to current directory)',
      );
  }

  @override
  String get name => commandName;

  @override
  String get description => commandDescription;

  @override
  FutureOr<void>? run() async {
    final dryRun = argResults!.flag('dry-run');
    final repoRoot = await _getRepoRootPath();
    final pkgPath = argResults![pathOption] as String? ??
        p.relative(Directory.current.path, from: repoRoot);
    await _runPublishFlow(
      repoRoot: repoRoot,
      pkgPath: pkgPath,
      dryRunOnly: dryRun,
    );
  }
}
