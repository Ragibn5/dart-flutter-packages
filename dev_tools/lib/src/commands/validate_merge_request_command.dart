import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/use_cases/git/get_repo_root_path.dart';
import 'package:dev_tools/src/use_cases/validate_release_merge_request.dart';

class ValidateMergeRequestCommand extends Command<void> {
  static const String commandName = 'validate-mr';
  static const String commandDescription =
      'Gate an MR into main: validates every release-candidate package '
      'touched by the diff is complete and ready to publish.';
  static const String fromOption = 'from';
  static const String toOption = 'to';

  final GetRepoRootPath _getRepoRootPath;
  final ValidateReleaseMergeRequest _validateMergeRequest;

  ValidateMergeRequestCommand({
    GetRepoRootPath getRepoRootPath = const GetRepoRootPath(),
    ValidateReleaseMergeRequest validateMergeRequest =
        const ValidateReleaseMergeRequest(),
  })  : _getRepoRootPath = getRepoRootPath,
        _validateMergeRequest = validateMergeRequest {
    argParser
      ..addOption(
        fromOption,
        defaultsTo: 'HEAD',
        help: "The MR's source branch, i.e. what is being merged "
            '(default: the currently checked-out branch).',
      )
      ..addOption(
        toOption,
        defaultsTo: 'origin/main',
        help: "The MR's target branch, i.e. what it merges into.",
      );
  }

  @override
  String get name => commandName;

  @override
  String get description => commandDescription;

  @override
  FutureOr<void>? run() async {
    final repoRoot = await _getRepoRootPath();
    await _validateMergeRequest(
      repoRoot: repoRoot,
      fromBranch: argResults![fromOption] as String,
      toBranch: argResults![toOption] as String,
    );
  }
}
