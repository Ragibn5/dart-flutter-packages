import 'package:dev_tools/src/models/local_package_info.dart';
import 'package:dev_tools/src/models/package_identity.dart';
import 'package:dev_tools/src/models/published_package_info.dart';
import 'package:dev_tools/src/models/release_candidate_package.dart';
import 'package:dev_tools/src/use_cases/publish/publish_validation_exception.dart';
import 'package:dev_tools/src/use_cases/publish/verify_release_completeness.dart';
import 'package:dev_tools/src/use_cases/validate_release_candidates.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockVerifyReleaseCompleteness extends Mock
    implements VerifyReleaseCompleteness {}

void main() {
  const repoRoot = '/fake/repo';
  const publishedVersions = PublishedPackageInfo(versions: ['0.9.0']);

  late _MockVerifyReleaseCompleteness verifyReleaseCompleteness;
  late ValidateReleaseCandidates sut;

  ReleaseCandidatePackage candidate(String path, String name) =>
      ReleaseCandidatePackage(
        localPackageInfo: LocalPackageInfo(
          repoRootRelativePath: path,
          packageIdentity: PackageIdentity(name: name, version: '1.0.0'),
        ),
        publishedPackageInfo: publishedVersions,
      );

  setUp(() {
    verifyReleaseCompleteness = _MockVerifyReleaseCompleteness();
    when(
      () => verifyReleaseCompleteness(
        any(),
        publishedPackageInfo: any(named: 'publishedPackageInfo'),
      ),
    ).thenAnswer((_) async {});

    sut = ValidateReleaseCandidates(
      verifyReleaseCompleteness: verifyReleaseCompleteness,
    );
  });

  test('should complete when there are no candidates', () async {
    await expectLater(
      sut(repoRoot: repoRoot, candidates: const []),
      completes,
    );
    verifyNever(
      () => verifyReleaseCompleteness(
        any(),
        publishedPackageInfo: any(named: 'publishedPackageInfo'),
      ),
    );
  });

  test('should complete when every candidate is release-complete', () async {
    final candidates = [
      candidate('pkg_a', 'pkg_a'),
      candidate('pkg_b', 'pkg_b')
    ];

    await expectLater(
      sut(repoRoot: repoRoot, candidates: candidates),
      completes,
    );
    verify(
      () => verifyReleaseCompleteness(
        '/fake/repo/pkg_a',
        publishedPackageInfo: publishedVersions,
      ),
    ).called(1);
    verify(
      () => verifyReleaseCompleteness(
        '/fake/repo/pkg_b',
        publishedPackageInfo: publishedVersions,
      ),
    ).called(1);
  });

  test(
      "should reuse each candidate's already-fetched pub.dev state instead "
      'of re-fetching it', () async {
    final candidates = [candidate('pkg_a', 'pkg_a')];

    await sut(repoRoot: repoRoot, candidates: candidates);

    verify(
      () => verifyReleaseCompleteness(
        any(),
        publishedPackageInfo: publishedVersions,
      ),
    ).called(1);
  });

  test('should throw aggregating problems from every failing candidate',
      () async {
    when(
      () => verifyReleaseCompleteness(
        '/fake/repo/pkg_a',
        publishedPackageInfo: any(named: 'publishedPackageInfo'),
      ),
    ).thenThrow(const PublishValidationException('pkg_a is broken.'));
    when(
      () => verifyReleaseCompleteness(
        '/fake/repo/pkg_b',
        publishedPackageInfo: any(named: 'publishedPackageInfo'),
      ),
    ).thenThrow(const PublishValidationException('pkg_b is broken.'));
    final candidates = [
      candidate('pkg_a', 'pkg_a'),
      candidate('pkg_b', 'pkg_b')
    ];

    await expectLater(
      sut(repoRoot: repoRoot, candidates: candidates),
      throwsA(
        isA<PublishValidationException>().having(
          (e) => e.message,
          'message',
          allOf(contains('pkg_a is broken.'), contains('pkg_b is broken.')),
        ),
      ),
    );
  });

  test('should still verify remaining candidates after an earlier failure',
      () async {
    when(
      () => verifyReleaseCompleteness(
        '/fake/repo/pkg_a',
        publishedPackageInfo: any(named: 'publishedPackageInfo'),
      ),
    ).thenThrow(const PublishValidationException('pkg_a is broken.'));
    final candidates = [
      candidate('pkg_a', 'pkg_a'),
      candidate('pkg_b', 'pkg_b')
    ];

    await expectLater(
      sut(repoRoot: repoRoot, candidates: candidates),
      throwsA(isA<PublishValidationException>()),
    );
    verify(
      () => verifyReleaseCompleteness(
        '/fake/repo/pkg_b',
        publishedPackageInfo: any(named: 'publishedPackageInfo'),
      ),
    ).called(1);
  });
}
