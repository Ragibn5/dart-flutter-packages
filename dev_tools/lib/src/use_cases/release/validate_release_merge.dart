import 'dart:io';

import 'package:dev_tools/src/use_cases/dart_flutter/find_packages.dart';
import 'package:dev_tools/src/use_cases/git/detect_changes_in_folder.dart';
import 'package:dev_tools/src/use_cases/git/get_tag_format.dart';
import 'package:dev_tools/src/use_cases/git/tag_exists.dart';
import 'package:dev_tools/src/use_cases/release/find_release_candidate_packages.dart';
import 'package:dev_tools/src/use_cases/release/package_registry_client.dart';
import 'package:dev_tools/src/use_cases/release/release_validation_exception.dart';
import 'package:dev_tools/src/use_cases/release/standard_release_checks_builder.dart';
import 'package:dev_tools/src/use_cases/release/verify_release_completeness.dart';
import 'package:path/path.dart' as p;

const _greenTick = '\x1B[32m✓\x1B[0m';
const _redCross = '\x1B[31m✗\x1B[0m';

/// Orchestrates the MR-to-target-branch release gate end to end.
class ValidateReleaseMerge {
  final TagExists _tagExists;
  final GetTagFormat _gitTagFormat;
  final DetectChangesInFolder _detectChangesInFolder;
  final FindReleaseCandidatePackages _findReleaseCandidates;
  final VerifyReleaseCompleteness _verifyReleaseCompleteness;
  final BuildStandardReleaseChecksBuilder _buildStandardReleaseChecks;

  const ValidateReleaseMerge({
    TagExists tagExists = const TagExists(),
    GetTagFormat gitTagFormat = const GetTagFormat(ResolveGitTagFormat()),
    DetectChangesInFolder detectChangesInFolder = const DetectChangesInFolder(),
    FindReleaseCandidatePackages findReleaseCandidatePackages =
        const FindReleaseCandidatePackages(),
    VerifyReleaseCompleteness verifyReleaseCompleteness =
        const VerifyReleaseCompleteness(),
    BuildStandardReleaseChecksBuilder buildStandardReleaseChecks =
        const BuildStandardReleaseChecksBuilder(),
  })  : _detectChangesInFolder = detectChangesInFolder,
        _findReleaseCandidates = findReleaseCandidatePackages,
        _verifyReleaseCompleteness = verifyReleaseCompleteness,
        _tagExists = tagExists,
        _gitTagFormat = gitTagFormat,
        _buildStandardReleaseChecks = buildStandardReleaseChecks;

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
  /// - [TagLookupException] when a tag lookup fails for a reason other than
  ///   the tag not existing (see [TagExists]).
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

    final checks = _buildStandardReleaseChecks.build(_gitTagFormat);
    final validPackages = <String>{};
    final issuesMap = <String, List<String>>{};
    for (final candidate in candidates) {
      final packagePath = p.join(repoRoot, candidate.repoRootRelativePath);
      final identity = candidate.packageIdentity;
      final tag = _gitTagFormat(name: identity.name, version: identity.version);
      final tagAlreadyExists = await _tagExists(tag, repoRoot: repoRoot);
      final completenessIssues = await _verifyReleaseCompleteness(
        packagePath,
        publishedPackageInfo: candidate.publishedPackageInfo,
        checks: checks,
      );
      final issues = <String>[
        if (tagAlreadyExists) 'Tag $tag already exists.',
        ...completenessIssues.map((i) => i.issueMessage),
      ];

      if (issues.isNotEmpty) {
        issuesMap[identity.name] = issues;
      } else {
        validPackages.add(identity.name);
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
      'Found ${candidates.length} release candidate(s):\n'
      '${summaryLines.join('\n')}',
    );

    if (issuesMap.isNotEmpty) {
      throw ReleaseValidationException(
        '${issuesMap.length} release candidate(s) are incomplete.',
      );
    }
  }
}
