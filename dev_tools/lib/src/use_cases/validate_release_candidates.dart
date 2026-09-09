import 'package:dev_tools/src/models/release_candidate_package.dart';
import 'package:dev_tools/src/use_cases/publish/publish_validation_exception.dart';
import 'package:dev_tools/src/use_cases/publish/verify_release_completeness.dart';
import 'package:path/path.dart' as p;

/// Runs the release-completeness gate over every release candidate.
///
/// This is the MR-to-main check: a merge is blocked if any candidate
/// package is not ready to be published.
class ValidateReleaseCandidates {
  final VerifyReleaseCompleteness _verifyReleaseCompleteness;

  const ValidateReleaseCandidates({
    VerifyReleaseCompleteness verifyReleaseCompleteness =
        const VerifyReleaseCompleteness(),
  }) : _verifyReleaseCompleteness = verifyReleaseCompleteness;

  /// Verifies release completeness for every candidate.
  ///
  /// Params:
  /// - `repoRoot`: absolute path to the repository root.
  /// - `candidates`: packages to verify, as found by
  ///   `FindReleaseCandidatePackages`.
  ///
  /// Notes: runs the check for every candidate rather than stopping at the
  /// first failure, and throws [PublishValidationException] aggregating the
  /// problems from every package that failed, if any did.
  Future<void> call({
    required String repoRoot,
    required List<ReleaseCandidatePackage> candidates,
  }) async {
    final problems = <String>[];
    for (final candidate in candidates) {
      final packagePath = p.join(repoRoot, candidate.repoRootRelativePath);
      try {
        await _verifyReleaseCompleteness(
          packagePath,
          publishedPackageInfo: candidate.publishedPackageInfo,
        );
      } on PublishValidationException catch (e) {
        problems.add(e.message);
      }
    }

    if (problems.isNotEmpty) {
      throw PublishValidationException(problems.join('\n\n'));
    }
  }
}
