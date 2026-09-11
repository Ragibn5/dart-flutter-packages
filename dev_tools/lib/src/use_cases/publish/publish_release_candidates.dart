import 'dart:io';

import 'package:dev_tools/src/use_cases/git/create_and_push_tag.dart';
import 'package:dev_tools/src/use_cases/git/detect_changes_in_folder.dart';
import 'package:dev_tools/src/use_cases/git/get_tag_format.dart';
import 'package:dev_tools/src/use_cases/publish/publish_batch_exception.dart';
import 'package:dev_tools/src/use_cases/publish/run_publish_flow.dart';
import 'package:dev_tools/src/use_cases/release/find_release_candidate_packages.dart';

const _greenTick = '\x1B[32m✓\x1B[0m';
const _redCross = '\x1B[31m✗\x1B[0m';

/// Orchestrates publishing every release candidate introduced by a merge to
/// the release branch (e.g. `main`), and tagging each one that publishes
/// successfully.
///
/// Runs independently per candidate — one failing doesn't stop the rest —
/// then reports a per-package summary and fails the batch (via
/// [PublishBatchException]) if any candidate failed.
class PublishReleaseCandidates {
  final GetTagFormat _gitTagFormat;
  final CreateAndPushTag _createAndPushTag;
  final DetectChangesInFolder _detectChangesInFolder;
  final FindReleaseCandidatePackages _findReleaseCandidates;
  final RunPublishFlow _runPublishFlow;

  const PublishReleaseCandidates({
    GetTagFormat gitTagFormat = const GetTagFormat(ResolveGitTagFormat()),
    CreateAndPushTag createAndPushTag = const CreateAndPushTag(),
    DetectChangesInFolder detectChangesInFolder = const DetectChangesInFolder(),
    FindReleaseCandidatePackages findReleaseCandidatePackages =
        const FindReleaseCandidatePackages(),
    RunPublishFlow runPublishFlow = const RunPublishFlow(),
  })  : _detectChangesInFolder = detectChangesInFolder,
        _findReleaseCandidates = findReleaseCandidatePackages,
        _runPublishFlow = runPublishFlow,
        _gitTagFormat = gitTagFormat,
        _createAndPushTag = createAndPushTag;

  /// Publishes every release candidate introduced between `fromRef` and
  /// `toRef`, tagging each one that publishes successfully.
  ///
  /// Params:
  /// - `repoRoot`: absolute path to the repository root.
  /// - `fromRef`: the ref to diff from, i.e. the release branch's state
  ///   before this merge (e.g. the previous `main` commit).
  /// - `toRef`: the ref to diff against, i.e. the release branch's state
  ///   after this merge (e.g. `HEAD`).
  /// - `dryRun`: when true, run each candidate's dry-run publish only —
  ///   nothing is actually published, and no tags are created or pushed.
  ///
  /// Returns: nothing (void) when every candidate published successfully.
  ///
  /// Throws:
  /// - [GitDiffingException] when `git diff` fails.
  /// - `PackageFinderException` or `PackageRegistryLookupException` while
  ///   finding candidates (see [FindReleaseCandidatePackages]).
  /// - [PublishBatchException] listing every candidate that failed to
  ///   publish or tag, once all candidates have been attempted.
  ///
  /// Notes: publishes non-interactively and silently (see [RunPublishFlow]'s
  /// `interactive`/`verbose` params) — reports nothing per candidate, only
  /// the final summary, same as `ValidateReleaseMerge`.
  Future<void> call({
    required String repoRoot,
    required String fromRef,
    required String toRef,
    bool dryRun = false,
  }) async {
    stdout.writeln('Publishing release candidates...');

    final changedFiles = await _detectChangesInFolder(
      baseRef: fromRef,
      compareRef: toRef,
    );

    final candidates = await _findReleaseCandidates(
      repoRoot: repoRoot,
      changedFiles: changedFiles,
    );
    if (candidates.isEmpty) {
      stdout.writeln('No release candidates found; nothing to publish.');
      return;
    }

    // name -> tag, for every candidate that published and tagged cleanly.
    final published = <String, String>{};
    final issuesMap = <String, String>{};
    for (final candidate in candidates) {
      final identity = candidate.packageIdentity;
      final tag = _gitTagFormat(
        name: identity.name,
        version: identity.version,
      );
      try {
        // dryRunOnly follows the batch's own dryRun flag rather than
        // RunPublishFlow's default — a dry run here must never actually
        // publish, and tagging (below) must never run against one either.
        await _runPublishFlow(
          repoRoot: repoRoot,
          pkgPath: candidate.repoRootRelativePath,
          interactive: false,
          dryRunOnly: dryRun,
          verbose: false,
        );
        if (!dryRun) {
          await _createAndPushTag(tag, repoRoot: repoRoot);
        }

        published[identity.name] = tag;
      } catch (e) {
        issuesMap[identity.name] = e.toString();
      }
    }

    final tick = stdout.supportsAnsiEscapes ? _greenTick : '✓';
    final cross = stdout.supportsAnsiEscapes ? _redCross : '✗';
    final summaryLines = [
      for (final entry in published.entries) ...[
        if (dryRun)
          '  $tick ${entry.key}: dry-run publish passed'
        else ...[
          '  $tick ${entry.key}: published',
          '  $tick ${entry.key}: tagged (${entry.value})',
        ],
      ],
      for (final entry in issuesMap.entries) ...[
        '  $cross ${entry.key}:',
        for (final line in entry.value.split('\n')) '      $line',
      ],
    ];
    stdout.writeln(
      'Attempted ${candidates.length} release candidate(s):\n'
      '${summaryLines.join('\n')}',
    );

    if (issuesMap.isNotEmpty) {
      final verb = dryRun ? 'dry-run publish' : 'publish';
      throw PublishBatchException(
        '${issuesMap.length} release candidate(s) failed to $verb.',
      );
    }
  }
}
