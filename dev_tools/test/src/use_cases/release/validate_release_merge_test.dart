import 'package:dev_tools/src/models/local_package_info.dart';
import 'package:dev_tools/src/models/package_identity.dart';
import 'package:dev_tools/src/models/published_package_info.dart';
import 'package:dev_tools/src/models/release_candidate_package.dart';
import 'package:dev_tools/src/models/release_issue.dart';
import 'package:dev_tools/src/use_cases/git/detect_changes_in_folder.dart';
import 'package:dev_tools/src/use_cases/release/find_release_candidate_packages.dart';
import 'package:dev_tools/src/use_cases/release/release_validation_exception.dart';
import 'package:dev_tools/src/use_cases/release/validate_release_merge.dart';
import 'package:dev_tools/src/use_cases/release/verify_release_completeness.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockDetectChangesInFolder extends Mock
    implements DetectChangesInFolder {}

class _MockFindReleaseCandidatePackages extends Mock
    implements FindReleaseCandidatePackages {}

class _MockVerifyReleaseCompleteness extends Mock
    implements VerifyReleaseCompleteness {}

void main() {
  const repoRoot = '/fake/repo';
  const changedFiles = ['pkg_a/pubspec.yaml'];
  const publishedVersions = PublishedPackageInfo(versions: ['0.9.0']);

  late _MockDetectChangesInFolder detectChangesInFolder;
  late _MockFindReleaseCandidatePackages findReleaseCandidatePackages;
  late _MockVerifyReleaseCompleteness verifyReleaseCompleteness;
  late ValidateReleaseMerge sut;

  ReleaseCandidatePackage candidate(String path, String name) =>
      ReleaseCandidatePackage(
        localPackageInfo: LocalPackageInfo(
          repoRootRelativePath: path,
          packageIdentity: PackageIdentity(name: name, version: '1.0.0'),
        ),
        publishedPackageInfo: publishedVersions,
      );

  setUp(() {
    detectChangesInFolder = _MockDetectChangesInFolder();
    when(() => detectChangesInFolder(
          baseRef: any(named: 'baseRef'),
          compareRef: any(named: 'compareRef'),
        )).thenAnswer((_) async => changedFiles);

    findReleaseCandidatePackages = _MockFindReleaseCandidatePackages();
    when(() => findReleaseCandidatePackages(
          repoRoot: any(named: 'repoRoot'),
          changedFiles: any(named: 'changedFiles'),
        )).thenAnswer((_) async => const []);

    verifyReleaseCompleteness = _MockVerifyReleaseCompleteness();
    when(() => verifyReleaseCompleteness(
          any(),
          publishedPackageInfo: any(named: 'publishedPackageInfo'),
        )).thenAnswer((_) async => const <ReleaseIssue>[]);

    sut = ValidateReleaseMerge(
      detectChangesInFolder: detectChangesInFolder,
      findReleaseCandidatePackages: findReleaseCandidatePackages,
      verifyReleaseCompleteness: verifyReleaseCompleteness,
    );
  });

  test(
      'should diff with toBranch as the base and fromBranch as the compare '
      'ref', () async {
    await sut(
      repoRoot: repoRoot,
      fromBranch: 'feature/x',
      toBranch: 'origin/main',
    );

    verify(() => detectChangesInFolder(
          baseRef: 'origin/main',
          compareRef: 'feature/x',
        )).called(1);
  });

  test('should find release candidates among the diffed changed files',
      () async {
    await sut(
      repoRoot: repoRoot,
      fromBranch: 'feature/x',
      toBranch: 'origin/main',
    );

    verify(() => findReleaseCandidatePackages(
          repoRoot: repoRoot,
          changedFiles: changedFiles,
        )).called(1);
  });

  test(
      'should complete without verifying completeness when no candidates '
      'are found', () async {
    await expectLater(
      sut(repoRoot: repoRoot, fromBranch: 'feature/x', toBranch: 'main'),
      completes,
    );

    verifyNever(() => verifyReleaseCompleteness(
          any(),
          publishedPackageInfo: any(named: 'publishedPackageInfo'),
        ));
  });

  test('should verify completeness for every found candidate', () async {
    final candidates = [
      candidate('pkg_a', 'pkg_a'),
      candidate('pkg_b', 'pkg_b'),
    ];
    when(() => findReleaseCandidatePackages(
          repoRoot: any(named: 'repoRoot'),
          changedFiles: any(named: 'changedFiles'),
        )).thenAnswer((_) async => candidates);

    await sut(repoRoot: repoRoot, fromBranch: 'feature/x', toBranch: 'main');

    verify(() => verifyReleaseCompleteness(
          '/fake/repo/pkg_a',
          publishedPackageInfo: publishedVersions,
        )).called(1);
    verify(() => verifyReleaseCompleteness(
          '/fake/repo/pkg_b',
          publishedPackageInfo: publishedVersions,
        )).called(1);
  });

  test(
      "should reuse each candidate's already-fetched registry state instead "
      'of re-fetching it', () async {
    final candidates = [candidate('pkg_a', 'pkg_a')];
    when(() => findReleaseCandidatePackages(
          repoRoot: any(named: 'repoRoot'),
          changedFiles: any(named: 'changedFiles'),
        )).thenAnswer((_) async => candidates);

    await sut(repoRoot: repoRoot, fromBranch: 'feature/x', toBranch: 'main');

    verify(() => verifyReleaseCompleteness(
          any(),
          publishedPackageInfo: publishedVersions,
        )).called(1);
  });

  test('should throw after checking every candidate when some have issues',
      () async {
    when(() => findReleaseCandidatePackages(
          repoRoot: any(named: 'repoRoot'),
          changedFiles: any(named: 'changedFiles'),
        )).thenAnswer((_) async => [
          candidate('pkg_a', 'pkg_a'),
          candidate('pkg_b', 'pkg_b'),
        ]);
    when(() => verifyReleaseCompleteness(
          '/fake/repo/pkg_a',
          publishedPackageInfo: any(named: 'publishedPackageInfo'),
        )).thenAnswer((_) async => const [ReleaseIssue('pkg_a is broken.')]);
    when(() => verifyReleaseCompleteness(
          '/fake/repo/pkg_b',
          publishedPackageInfo: any(named: 'publishedPackageInfo'),
        )).thenAnswer((_) async => const [ReleaseIssue('pkg_b is broken.')]);

    await expectLater(
      sut(repoRoot: repoRoot, fromBranch: 'feature/x', toBranch: 'main'),
      throwsA(isA<ReleaseValidationException>()),
    );

    verify(() => verifyReleaseCompleteness(
          '/fake/repo/pkg_a',
          publishedPackageInfo: any(named: 'publishedPackageInfo'),
        )).called(1);
    verify(() => verifyReleaseCompleteness(
          '/fake/repo/pkg_b',
          publishedPackageInfo: any(named: 'publishedPackageInfo'),
        )).called(1);
  });

  test('should not throw when every candidate is complete', () async {
    when(() => findReleaseCandidatePackages(
          repoRoot: any(named: 'repoRoot'),
          changedFiles: any(named: 'changedFiles'),
        )).thenAnswer((_) async => [candidate('pkg_a', 'pkg_a')]);

    await expectLater(
      sut(repoRoot: repoRoot, fromBranch: 'feature/x', toBranch: 'main'),
      completes,
    );
  });
}
