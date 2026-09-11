import 'package:dev_tools/src/models/local_package_info.dart';
import 'package:dev_tools/src/models/package_identity.dart';
import 'package:dev_tools/src/models/published_package_info.dart';
import 'package:dev_tools/src/models/release_candidate_package.dart';
import 'package:dev_tools/src/use_cases/git/create_and_push_tag.dart';
import 'package:dev_tools/src/use_cases/git/detect_changes_in_folder.dart';
import 'package:dev_tools/src/use_cases/git/get_tag_format.dart';
import 'package:dev_tools/src/use_cases/publish/publish_batch_exception.dart';
import 'package:dev_tools/src/use_cases/publish/publish_release_candidates.dart';
import 'package:dev_tools/src/use_cases/publish/run_publish_flow.dart';
import 'package:dev_tools/src/use_cases/release/find_release_candidate_packages.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockDetectChangesInFolder extends Mock
    implements DetectChangesInFolder {}

class _MockFindReleaseCandidatePackages extends Mock
    implements FindReleaseCandidatePackages {}

class _MockRunPublishFlow extends Mock implements RunPublishFlow {}

class _MockCreateAndPushTag extends Mock implements CreateAndPushTag {}

class _MockResolveGitTagFormat extends Mock implements ResolveGitTagFormat {}

void main() {
  const repoRoot = '/fake/repo';
  const changedFiles = ['pkg_a/pubspec.yaml'];
  const publishedVersions = PublishedPackageInfo(versions: ['0.9.0']);

  late _MockDetectChangesInFolder detectChangesInFolder;
  late _MockFindReleaseCandidatePackages findReleaseCandidatePackages;
  late _MockRunPublishFlow runPublishFlow;
  late _MockCreateAndPushTag createAndPushTag;
  late _MockResolveGitTagFormat resolveGitTagFormat;
  late PublishReleaseCandidates sut;

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

    runPublishFlow = _MockRunPublishFlow();
    when(() => runPublishFlow(
          repoRoot: any(named: 'repoRoot'),
          pkgPath: any(named: 'pkgPath'),
          interactive: any(named: 'interactive'),
          dryRunOnly: any(named: 'dryRunOnly'),
          verbose: any(named: 'verbose'),
        )).thenAnswer((_) async {});

    createAndPushTag = _MockCreateAndPushTag();
    when(() => createAndPushTag(any(), repoRoot: any(named: 'repoRoot')))
        .thenAnswer((_) async {});

    resolveGitTagFormat = _MockResolveGitTagFormat();
    when(() => resolveGitTagFormat()).thenReturn('{name}-{version}');

    sut = PublishReleaseCandidates(
      detectChangesInFolder: detectChangesInFolder,
      findReleaseCandidatePackages: findReleaseCandidatePackages,
      runPublishFlow: runPublishFlow,
      createAndPushTag: createAndPushTag,
      gitTagFormat: GetTagFormat(resolveGitTagFormat),
    );
  });

  test('should diff with fromRef as the base and toRef as the compare ref',
      () async {
    await sut(repoRoot: repoRoot, fromRef: 'main~1', toRef: 'main');

    verify(() => detectChangesInFolder(
          baseRef: 'main~1',
          compareRef: 'main',
        )).called(1);
  });

  test('should find release candidates among the diffed changed files',
      () async {
    await sut(repoRoot: repoRoot, fromRef: 'main~1', toRef: 'main');

    verify(() => findReleaseCandidatePackages(
          repoRoot: repoRoot,
          changedFiles: changedFiles,
        )).called(1);
  });

  test('should complete without publishing when no candidates are found',
      () async {
    await expectLater(
      sut(repoRoot: repoRoot, fromRef: 'main~1', toRef: 'main'),
      completes,
    );

    verifyNever(() => runPublishFlow(
          repoRoot: any(named: 'repoRoot'),
          pkgPath: any(named: 'pkgPath'),
          interactive: any(named: 'interactive'),
          dryRunOnly: any(named: 'dryRunOnly'),
          verbose: any(named: 'verbose'),
        ));
  });

  test('should publish every found candidate non-interactively and quietly',
      () async {
    when(() => findReleaseCandidatePackages(
          repoRoot: any(named: 'repoRoot'),
          changedFiles: any(named: 'changedFiles'),
        )).thenAnswer((_) async => [
          candidate('pkg_a', 'pkg_a'),
          candidate('pkg_b', 'pkg_b'),
        ]);

    await sut(repoRoot: repoRoot, fromRef: 'main~1', toRef: 'main');

    verify(() => runPublishFlow(
          repoRoot: repoRoot,
          pkgPath: 'pkg_a',
          interactive: false,
          dryRunOnly: false,
          verbose: false,
        )).called(1);
    verify(() => runPublishFlow(
          repoRoot: repoRoot,
          pkgPath: 'pkg_b',
          interactive: false,
          dryRunOnly: false,
          verbose: false,
        )).called(1);
  });

  test('should tag every candidate that publishes successfully', () async {
    when(() => findReleaseCandidatePackages(
          repoRoot: any(named: 'repoRoot'),
          changedFiles: any(named: 'changedFiles'),
        )).thenAnswer((_) async => [candidate('pkg_a', 'pkg_a')]);

    await sut(repoRoot: repoRoot, fromRef: 'main~1', toRef: 'main');

    verify(() => createAndPushTag('pkg_a-1.0.0', repoRoot: repoRoot)).called(1);
  });

  test(
      'should follow the dryRun flag rather than publishing for real when '
      'set', () async {
    when(() => findReleaseCandidatePackages(
          repoRoot: any(named: 'repoRoot'),
          changedFiles: any(named: 'changedFiles'),
        )).thenAnswer((_) async => [candidate('pkg_a', 'pkg_a')]);

    await sut(
      repoRoot: repoRoot,
      fromRef: 'main~1',
      toRef: 'main',
      dryRun: true,
    );

    verify(() => runPublishFlow(
          repoRoot: repoRoot,
          pkgPath: 'pkg_a',
          interactive: false,
          dryRunOnly: true,
          verbose: false,
        )).called(1);
  });

  test('should not create or push a tag on a dry run', () async {
    when(() => findReleaseCandidatePackages(
          repoRoot: any(named: 'repoRoot'),
          changedFiles: any(named: 'changedFiles'),
        )).thenAnswer((_) async => [candidate('pkg_a', 'pkg_a')]);

    await sut(
      repoRoot: repoRoot,
      fromRef: 'main~1',
      toRef: 'main',
      dryRun: true,
    );

    verifyNever(
      () => createAndPushTag(any(), repoRoot: any(named: 'repoRoot')),
    );
  });

  test('should attempt every candidate even when one fails to publish',
      () async {
    when(() => findReleaseCandidatePackages(
          repoRoot: any(named: 'repoRoot'),
          changedFiles: any(named: 'changedFiles'),
        )).thenAnswer((_) async => [
          candidate('pkg_a', 'pkg_a'),
          candidate('pkg_b', 'pkg_b'),
        ]);
    when(() => runPublishFlow(
          repoRoot: any(named: 'repoRoot'),
          pkgPath: 'pkg_a',
          interactive: any(named: 'interactive'),
          dryRunOnly: any(named: 'dryRunOnly'),
          verbose: any(named: 'verbose'),
        )).thenThrow(const PublishFailedException('Error: Publishing failed.'));

    await expectLater(
      sut(repoRoot: repoRoot, fromRef: 'main~1', toRef: 'main'),
      throwsA(isA<PublishBatchException>()),
    );

    verify(() => runPublishFlow(
          repoRoot: repoRoot,
          pkgPath: 'pkg_b',
          interactive: false,
          dryRunOnly: false,
          verbose: false,
        )).called(1);
    verify(() => createAndPushTag('pkg_b-1.0.0', repoRoot: repoRoot)).called(1);
    verifyNever(() => createAndPushTag('pkg_a-1.0.0', repoRoot: repoRoot));
  });

  test('should not throw when every candidate publishes successfully',
      () async {
    when(() => findReleaseCandidatePackages(
          repoRoot: any(named: 'repoRoot'),
          changedFiles: any(named: 'changedFiles'),
        )).thenAnswer((_) async => [candidate('pkg_a', 'pkg_a')]);

    await expectLater(
      sut(repoRoot: repoRoot, fromRef: 'main~1', toRef: 'main'),
      completes,
    );
  });
}
