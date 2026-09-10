import 'dart:io';

import 'package:dev_tools/src/use_cases/dart_flutter/find_packages.dart';
import 'package:dev_tools/src/use_cases/git/detect_changes_in_folder.dart';
import 'package:dev_tools/src/use_cases/release/find_release_candidate_packages.dart';
import 'package:dev_tools/src/use_cases/release/package_registry_client.dart';
import 'package:dev_tools/src/use_cases/release/release_validation_exception.dart';
import 'package:dev_tools/src/use_cases/release/verify_release_completeness.dart';
import 'package:path/path.dart' as p;

const _greenTick = '\x1B[32m✓\x1B[0m';
const _redCross = '\x1B[31m✗\x1B[0m';

/// Orchestrates the MR-to-target-branch release gate end to end.
///
/// Diffs `fromBranch`/`toBranch`, finds release-candidate packages among the
/// changed files, and runs the release-completeness gate over them.
class ValidateReleaseMerge {
  final DetectChangesInFolder _detectChangesInFolder;
  final FindReleaseCandidatePackages _findReleaseCandidates;
  final VerifyReleaseCompleteness _verifyReleaseCompleteness;

  const ValidateReleaseMerge({
    DetectChangesInFolder detectChangesInFolder = const DetectChangesInFolder(),
    FindReleaseCandidatePackages findReleaseCandidatePackages =
        const FindReleaseCandidatePackages(),
    VerifyReleaseCompleteness verifyReleaseCompleteness =
        const VerifyReleaseCompleteness(),
  })  : _detectChangesInFolder = detectChangesInFolder,
        _findReleaseCandidates = findReleaseCandidatePackages,
        _verifyReleaseCompleteness = verifyReleaseCompleteness;

  /// Runs the MR gate.
  ///
  /// Params:
  /// - `repoRoot`: absolute path to the repository root.
  /// - `fromBranch`: the MR's source branch, i.e. what is being merged
  ///   (e.g. `release/1.0.0`, or `HEAD` when that branch is checked out).
  /// - `toBranch`: the MR's target branch, i.e. what it merges into
  ///   (e.g. `origin/main`, `origin/release`).
  ///
  /// Returns: nothing (void) when every candidate is complete.
  ///
  /// Throws:
  /// - [GitDiffingException] when `git diff` fails.
  /// - [PackageFinderException] or [PackageRegistryLookupException] while
  ///   finding candidates (see [FindReleaseCandidatePackages]).
  /// - `PackageIdentityException` while checking a candidate's completeness
  ///   (see [VerifyReleaseCompleteness]).
  /// - [ReleaseValidationException] listing every candidate with issues,
  ///   once all candidates have been checked, so the MR gate fails.
  ///
  /// Notes: runs the completeness check for every candidate rather than
  /// stopping at the first failure. Reports progress to stdout.
  Future<void> call({
    required String repoRoot,
    required String fromBranch,
    required String toBranch,
  }) async {
    stdout.writeln('Validating release merge...');

    // Diffs against the merge base of toBranch/fromBranch (git's `...`
    // syntax), so this yields exactly the changes fromBranch introduces on
    // top of toBranch — baseRef is the target, compareRef is the source.
    final changedFiles = await _detectChangesInFolder(
      baseRef: toBranch,
      compareRef: fromBranch,
    );

    final candidates = await _findReleaseCandidates(
      repoRoot: repoRoot,
      changedFiles: changedFiles,
    );
    if (candidates.isEmpty) {
      stdout.writeln('No release candidates found; nothing to validate.');
      return;
    }

    final validPackages = <String>{};
    final issuesMap = <String, List<String>>{};
    for (final candidate in candidates) {
      final packagePath = p.join(repoRoot, candidate.repoRootRelativePath);
      final packageReleaseIssues = await _verifyReleaseCompleteness(
        packagePath,
        publishedPackageInfo: candidate.publishedPackageInfo,
      );
      if (packageReleaseIssues.isNotEmpty) {
        issuesMap[candidate.packageIdentity.name] =
            packageReleaseIssues.map((i) => i.issueMessage).toList();
      } else {
        validPackages.add(candidate.packageIdentity.name);
      }
    }

    final tick = stdout.supportsAnsiEscapes ? _greenTick : '✓';
    final cross = stdout.supportsAnsiEscapes ? _redCross : '✗';
    final summaryLines = [
      for (final name in validPackages) '  $tick $name: OK',
      for (final entry in issuesMap.entries) ...[
        '  $cross ${entry.key}:',
        for (final issue in entry.value) '      - $issue',
      ],
    ];
    stdout.writeln(
      'Found ${candidates.length} release candidate(s)\n'
      '${summaryLines.join('\n')}',
    );

    if (issuesMap.isNotEmpty) {
      throw ReleaseValidationException(
        'Error: ${issuesMap.length} release candidate(s) are incomplete.',
      );
    }
  }
}
