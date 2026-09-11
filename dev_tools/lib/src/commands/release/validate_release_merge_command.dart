import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/use_cases/git/get_repo_root_path.dart';
import 'package:dev_tools/src/use_cases/git/get_tag_format.dart';
import 'package:dev_tools/src/use_cases/release/validate_release_merge.dart';

class ValidateReleaseMergeCommand extends Command<void> {
  static const String commandName = 'validate-release-mr';
  static const String commandDescription =
      'Gate a release MR into its target branch: '
      'validates that every release-candidate packages touched by the diff '
      'is complete and ready to be published.\n\n'
      'Notes:\n'
      '- Tag style defaults to "${ResolveGitTagFormat.defaultGitTagFormat}".\n'
      // ignore: lines_longer_than_80_chars
      '  To customize, override the ${ResolveGitTagFormat.gitTagFormatEnvVar} env var.\n'
      '  Supported placeholders are "{name}" & "{version}".'
      '  For example, a custom override might be "{name}-v{version}".';

  static const String fromOption = 'from';
  static const String toOption = 'to';

  final GetRepoRootPath _getRepoRootPath;
  final ValidateReleaseMerge _validateReleaseMerge;

  ValidateReleaseMergeCommand({
    GetRepoRootPath getRepoRootPath = const GetRepoRootPath(),
    ValidateReleaseMerge validateReleaseMergeRequest =
        const ValidateReleaseMerge(),
  })  : _getRepoRootPath = getRepoRootPath,
        _validateReleaseMerge = validateReleaseMergeRequest {
    argParser
      ..addOption(
        fromOption,
        defaultsTo: 'HEAD',
        help: "The MR's source branch, i.e. what is being merged "
            '(default: the currently checked-out branch).',
      )
      ..addOption(
        toOption,
        mandatory: true,
        help: "The MR's target branch, i.e. what it merges into "
            '(e.g. `origin/main``).',
      );
  }

  @override
  String get name => commandName;

  @override
  String get description => commandDescription;

  @override
  FutureOr<void>? run() async {
    final repoRoot = await _getRepoRootPath();
    await _validateReleaseMerge(
      repoRoot: repoRoot,
      fromBranch: argResults![fromOption] as String,
      toBranch: argResults![toOption] as String,
    );
  }
}
