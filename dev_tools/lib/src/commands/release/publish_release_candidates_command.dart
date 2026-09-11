import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/use_cases/git/get_repo_root_path.dart';
import 'package:dev_tools/src/use_cases/git/get_tag_format.dart';
import 'package:dev_tools/src/use_cases/publish/publish_release_candidates.dart';

class PublishReleaseCandidatesCommand extends Command<void> {
  static const String commandName = 'publish-release-candidates';
  static const String commandDescription =
      'Publish and tag release candidates.\n\n'
      'Notes:\n'
      '- Tag style defaults to "${ResolveGitTagFormat.defaultGitTagFormat}".\n'
      // ignore: lines_longer_than_80_chars
      '  To customize, override the ${ResolveGitTagFormat.gitTagFormatEnvVar} env var.\n'
      '  Supported placeholders are "{name}" & "{version}".'
      '  For example, a custom override might be "{name}@{version}".';

  static const String fromOption = 'from';
  static const String toOption = 'to';
  static const String dryRunFlag = 'dry-run';

  final GetRepoRootPath _getRepoRootPath;
  final PublishReleaseCandidates _publishReleaseCandidates;

  PublishReleaseCandidatesCommand({
    GetRepoRootPath getRepoRootPath = const GetRepoRootPath(),
    PublishReleaseCandidates publishReleaseCandidates =
        const PublishReleaseCandidates(),
  })  : _getRepoRootPath = getRepoRootPath,
        _publishReleaseCandidates = publishReleaseCandidates {
    argParser
      ..addOption(
        fromOption,
        defaultsTo: 'HEAD^',
        help: 'The release branch state before this merge '
            '(default: the previous commit).',
      )
      ..addOption(
        toOption,
        defaultsTo: 'HEAD',
        help: 'The release branch state after this merge '
            '(default: the currently checked-out commit).',
      )
      ..addFlag(
        dryRunFlag,
        negatable: false,
        help: "Run each candidate's dry-run publish only; publish nothing "
            'and create no tags.',
      );
  }

  @override
  String get name => commandName;

  @override
  String get description => commandDescription;

  @override
  FutureOr<void>? run() async {
    final repoRoot = await _getRepoRootPath();
    await _publishReleaseCandidates(
      repoRoot: repoRoot,
      fromRef: argResults![fromOption] as String,
      toRef: argResults![toOption] as String,
      dryRun: argResults!.flag(dryRunFlag),
    );
  }
}
