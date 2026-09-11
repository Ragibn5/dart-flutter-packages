import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/use_cases/git/get_repo_root_path.dart';
import 'package:dev_tools/src/use_cases/release/validate_release_merge.dart';

class ValidateReleaseMergeCommand extends Command<void> {
  static const String commandName = 'validate-release-mr';
  static const String commandDescription =
      'Gate a release MR into its target branch: '
      'validates that every release-candidate packages touched by the diff '
      'is complete and ready to be published. Uses the shared git-tag '
      "naming convention — see 'dev_tools git --help'.";

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
