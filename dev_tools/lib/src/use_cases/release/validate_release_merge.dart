import 'dart:io';

import 'package:dev_tools/src/use_cases/git/detect_changes_in_folder.dart';
import 'package:dev_tools/src/use_cases/publish/publish_validation_exception.dart';
import 'package:dev_tools/src/use_cases/release/find_release_candidate_packages.dart';
import 'package:dev_tools/src/use_cases/release/validate_release_candidates.dart';

/// Orchestrates the MR-to-target-branch release gate end to end.
///
/// Diffs `fromBranch`/`toBranch`, finds release-candidate packages among the
/// changed files, and runs the release-completeness gate over them.
class ValidateReleaseMerge {
  final DetectChangesInFolder _detectChangesInFolder;
  final FindReleaseCandidatePackages _findReleaseCandidatePackages;
  final ValidateReleaseCandidates _validateReleaseCandidates;

  const ValidateReleaseMerge({
    DetectChangesInFolder detectChangesInFolder = const DetectChangesInFolder(),
    FindReleaseCandidatePackages findReleaseCandidatePackages =
        const FindReleaseCandidatePackages(),
    ValidateReleaseCandidates validateReleaseCandidates =
        const ValidateReleaseCandidates(),
  })  : _detectChangesInFolder = detectChangesInFolder,
        _findReleaseCandidatePackages = findReleaseCandidatePackages,
        _validateReleaseCandidates = validateReleaseCandidates;

  /// Runs the MR gate.
  ///
  /// Params:
  /// - `repoRoot`: absolute path to the repository root.
  /// - `fromBranch`: the MR's source branch, i.e. what is being merged
  ///   (e.g. `release/1.0.0`, or `HEAD` when that branch is checked out).
  /// - `toBranch`: the MR's target branch, i.e. what it merges into
  ///   (e.g. `origin/main`, `origin/release`).
  ///
  /// Notes: throws [PublishValidationException] aggregating the problems
  /// from every failing candidate, if any did. Reports progress to stdout.
  Future<void> call({
    required String repoRoot,
    required String fromBranch,
    required String toBranch,
  }) async {
    // Diffs against the merge base of toBranch/fromBranch (git's `...`
    // syntax), so this yields exactly the changes fromBranch introduces on
    // top of toBranch — baseRef is the target, compareRef is the source.
    final changedFiles = await _detectChangesInFolder(
      baseRef: toBranch,
      compareRef: fromBranch,
    );

    final candidates = await _findReleaseCandidatePackages(
      repoRoot: repoRoot,
      changedFiles: changedFiles,
    );

    if (candidates.isEmpty) {
      stdout.writeln('No release candidates found; nothing to validate.');
      return;
    }

    stdout.writeln(
      'Found ${candidates.length} release candidate(s): '
      '${candidates.map((c) => c.packageIdentity.name).join(', ')}',
    );

    await _validateReleaseCandidates(
      repoRoot: repoRoot,
      candidates: candidates,
    );
  }
}
