import 'package:dev_tools/src/models/local_package_info.dart';
import 'package:dev_tools/src/models/package_identity.dart';
import 'package:dev_tools/src/models/published_package_info.dart';
import 'package:dev_tools/src/use_cases/publish/fetch_published_package_info.dart';
import 'package:dev_tools/src/use_cases/publish/find_packages.dart';
import 'package:dev_tools/src/use_cases/release/find_release_candidate_packages.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockFindPackages extends Mock implements FindPackages {}

class _MockFetchPublishedPackageInfo extends Mock
    implements FetchPublishedPackageInfo {}

void main() {
  const repoRoot = '/fake/repo';

  late _MockFindPackages findPackages;
  late _MockFetchPublishedPackageInfo fetchPublishedPackageVersions;
  late FindReleaseCandidatePackages sut;

  LocalPackageInfo localPackage(
    String path,
    String name,
    String version, {
    bool isPublishable = true,
  }) =>
      LocalPackageInfo(
        repoRootRelativePath: path,
        packageIdentity: PackageIdentity(
          name: name,
          version: version,
          isPublishable: isPublishable,
        ),
      );

  setUp(() {
    findPackages = _MockFindPackages();
    fetchPublishedPackageVersions = _MockFetchPublishedPackageInfo();

    when(() => fetchPublishedPackageVersions(any()))
        .thenAnswer((_) async => const PublishedPackageInfo());

    sut = FindReleaseCandidatePackages(
      findPackages: findPackages,
      fetchPublishedPackageVersions: fetchPublishedPackageVersions,
    );
  });

  void stubFoundPackages(List<LocalPackageInfo> packages) {
    when(
      () => findPackages(
        repoRoot: any(named: 'repoRoot'),
        filter: any(named: 'filter'),
      ),
    ).thenAnswer((invocation) async {
      final filter =
          invocation.namedArguments[#filter] as bool Function(LocalPackageInfo);
      return packages.where(filter).toList();
    });
  }

  test('should return a brand-new package as a candidate', () async {
    stubFoundPackages([localPackage('pkg_a', 'pkg_a', '1.0.0')]);

    final result = await sut(
      repoRoot: repoRoot,
      changedFiles: ['pkg_a/lib/pkg_a.dart'],
    );

    expect(result, hasLength(1));
    expect(result.single.repoRootRelativePath, 'pkg_a');
    expect(result.single.packageIdentity.name, 'pkg_a');
  });

  test('should return a package with a version bump as a candidate', () async {
    stubFoundPackages([localPackage('pkg_a', 'pkg_a', '1.1.0')]);
    when(() => fetchPublishedPackageVersions('pkg_a')).thenAnswer(
      (_) async => const PublishedPackageInfo(
        latestVersion: '1.0.0',
        versions: ['1.0.0'],
      ),
    );

    final result = await sut(
      repoRoot: repoRoot,
      changedFiles: ['pkg_a/lib/pkg_a.dart'],
    );

    expect(result, hasLength(1));
    expect(result.single.packageIdentity.version, '1.1.0');
  });

  test(
      'should not return a package whose current version is already '
      'published', () async {
    stubFoundPackages([localPackage('pkg_a', 'pkg_a', '1.0.0')]);
    when(() => fetchPublishedPackageVersions('pkg_a')).thenAnswer(
      (_) async => const PublishedPackageInfo(
        latestVersion: '1.0.0',
        versions: ['1.0.0'],
      ),
    );

    final result = await sut(
      repoRoot: repoRoot,
      changedFiles: ['pkg_a/README.md'],
    );

    expect(result, isEmpty);
  });

  test('should ignore a package with publish_to: none', () async {
    stubFoundPackages([
      localPackage('my_app', 'my_app', '1.0.0', isPublishable: false),
    ]);

    final result = await sut(
      repoRoot: repoRoot,
      changedFiles: ['my_app/lib/main.dart'],
    );

    expect(result, isEmpty);
    verifyNever(() => fetchPublishedPackageVersions(any()));
  });

  test('should ignore a package with no changed files', () async {
    stubFoundPackages([localPackage('pkg_a', 'pkg_a', '1.0.0')]);

    final result = await sut(
      repoRoot: repoRoot,
      changedFiles: ['docs/readme.md'],
    );

    expect(result, isEmpty);
    verifyNever(() => fetchPublishedPackageVersions(any()));
  });

  test('should treat a change inside a nested package directory as touched',
      () async {
    stubFoundPackages([localPackage('packages/pkg_a', 'pkg_a', '1.0.0')]);

    final result = await sut(
      repoRoot: repoRoot,
      changedFiles: ['packages/pkg_a/lib/pkg_a.dart'],
    );

    expect(result, hasLength(1));
  });

  test('should return multiple candidates when several packages are touched',
      () async {
    stubFoundPackages([
      localPackage('pkg_a', 'pkg_a', '1.0.0'),
      localPackage('pkg_b', 'pkg_b', '2.0.0'),
    ]);

    final result = await sut(
      repoRoot: repoRoot,
      changedFiles: ['pkg_a/lib/pkg_a.dart', 'pkg_b/lib/pkg_b.dart'],
    );

    expect(
      result.map((c) => c.packageIdentity.name).toList()..sort(),
      ['pkg_a', 'pkg_b'],
    );
  });

  test('should propagate PubDevLookupException', () async {
    stubFoundPackages([localPackage('pkg_a', 'pkg_a', '1.0.0')]);
    when(() => fetchPublishedPackageVersions('pkg_a')).thenThrow(
      const PubDevLookupException('connection timeout'),
    );

    await expectLater(
      sut(repoRoot: repoRoot, changedFiles: ['pkg_a/lib/pkg_a.dart']),
      throwsA(isA<PubDevLookupException>()),
    );
  });
}
