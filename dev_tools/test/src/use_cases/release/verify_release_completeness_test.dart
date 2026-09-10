// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:dev_tools/src/models/package_identity.dart';
import 'package:dev_tools/src/models/published_package_info.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/read_package_identity.dart';
import 'package:dev_tools/src/use_cases/release/package_registry_client.dart';
import 'package:dev_tools/src/use_cases/release/verify_release_completeness.dart';
import 'package:dev_tools/src/use_cases/release/verify_versioned_files.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockReadPackageIdentity extends Mock implements ReadPackageIdentity {}

class _MockVerifyVersionedFiles extends Mock implements VerifyVersionedFiles {}

class _MockPackageRegistryClient extends Mock
    implements PackageRegistryClient {}

void main() {
  const packagePath = '/fake/repo/pkg';

  late _MockReadPackageIdentity readPackageIdentity;
  late _MockVerifyVersionedFiles verifyVersionedFiles;
  late _MockPackageRegistryClient packageRegistryClient;
  late VerifyReleaseCompleteness sut;

  VerifyReleaseCompleteness buildSut() => VerifyReleaseCompleteness(
        readPackageIdentity: readPackageIdentity,
        verifyVersionedFiles: verifyVersionedFiles,
        packageRegistryClient: packageRegistryClient,
      );

  setUp(() {
    readPackageIdentity = _MockReadPackageIdentity();
    verifyVersionedFiles = _MockVerifyVersionedFiles();
    packageRegistryClient = _MockPackageRegistryClient();

    when(() => readPackageIdentity(any())).thenAnswer(
      (_) async => const PackageIdentity(name: 'foo', version: '1.0.0'),
    );
    when(
      () => verifyVersionedFiles(
        packagePath: any(named: 'packagePath'),
        name: any(named: 'name'),
        version: any(named: 'version'),
        checks: any(named: 'checks'),
      ),
    ).thenAnswer((_) async => <String>[]);
    when(() => packageRegistryClient(any())).thenAnswer(
      (_) async => const PublishedPackageInfo(),
    );

    sut = buildSut();
  });

  test('should complete when the release is consistent', () async {
    await expectLater(sut(packagePath), completes);

    verify(() => readPackageIdentity(packagePath)).called(1);
    verify(
      () => verifyVersionedFiles(
        packagePath: packagePath,
        name: 'foo',
        version: '1.0.0',
        checks: any(named: 'checks'),
      ),
    ).called(1);
  });

  test('should report an issue when already published', () async {
    when(() => packageRegistryClient(any())).thenAnswer(
      (_) async => const PublishedPackageInfo(
        latestVersion: '1.0.0',
        versions: ['1.0.0'],
      ),
    );

    final issues = await sut(packagePath);

    expect(
      issues.map((i) => i.issueMessage),
      contains('foo@1.0.0 is already published.'),
    );
  });

  test('should report an issue when the release is older', () async {
    when(() => packageRegistryClient(any())).thenAnswer(
      (_) async => const PublishedPackageInfo(
        latestVersion: '2.0.0',
        versions: ['2.0.0'],
      ),
    );

    final issues = await sut(packagePath);

    expect(
      issues.map((i) => i.issueMessage),
      contains(
        'A newer version (2.0.0) is already published; '
        '1.0.0 must be greater.',
      ),
    );
  });

  test('should return an issue for each versioned file problem', () async {
    when(
      () => verifyVersionedFiles(
        packagePath: any(named: 'packagePath'),
        name: any(named: 'name'),
        version: any(named: 'version'),
        checks: any(named: 'checks'),
      ),
    ).thenAnswer((_) async => <String>[
          'CHANGELOG.md has no entry for 1.0.0.',
          'README.md does not reference foo-1.0.0 (git install).',
        ]);

    final issues = await sut(packagePath);

    expect(
      issues.map((i) => i.issueMessage),
      containsAll([
        'CHANGELOG.md has no entry for 1.0.0.',
        'README.md does not reference foo-1.0.0 (git install).',
      ]),
    );
  });

  test(
      'should use the injected publishedVersions instead of fetching from '
      'the registry', () async {
    final issues = await sut(
      packagePath,
      publishedPackageInfo: const PublishedPackageInfo(
        latestVersion: '1.0.0',
        versions: ['1.0.0'],
      ),
    );

    expect(
      issues.map((i) => i.issueMessage),
      contains('foo@1.0.0 is already published.'),
    );
    verifyNever(() => packageRegistryClient(any()));
  });

  test('should report an issue when the package registry cannot be reached',
      () async {
    when(() => packageRegistryClient(any())).thenThrow(
      const PackageRegistryLookupException('connection timeout'),
    );

    final issues = await sut(packagePath);

    expect(
      issues.map((i) => i.issueMessage),
      contains('Could not reach the package registry to verify foo: '
          'connection timeout'),
    );
  });

  test('should propagate PackageIdentityException', () async {
    when(() => readPackageIdentity(any())).thenThrow(
      const PackageIdentityException('Error: pubspec.yaml not found.'),
    );

    await expectLater(
      sut(packagePath),
      throwsA(isA<PackageIdentityException>()),
    );
  });

  test('should pass injected checks to VerifyVersionedFiles', () async {
    final customChecks = <String, VersionedFileCheck>{
      'install': VersionedFileCheck(
        filePath: 'docs/install.md',
        pattern: (name, version) => RegExp(RegExp.escape(version)),
        problem: (name, version) => 'docs/install.md lacks $version.',
      ),
    };

    await expectLater(
      sut(packagePath, checks: customChecks),
      completes,
    );

    verify(
      () => verifyVersionedFiles(
        packagePath: packagePath,
        name: 'foo',
        version: '1.0.0',
        checks: customChecks,
      ),
    ).called(1);
  });

  group('standard checks with real files', () {
    const pkgPath = 'pkg';

    late Directory tempDir;

    VerifyReleaseCompleteness buildRealFilesSut() => VerifyReleaseCompleteness(
          readPackageIdentity: readPackageIdentity,
          packageRegistryClient: packageRegistryClient,
        );

    setUp(() {
      tempDir = Directory.systemTemp
          .createTempSync('verify_release_completeness_test');
      Directory('${tempDir.path}/$pkgPath').createSync(recursive: true);
      when(() => packageRegistryClient(any()))
          .thenAnswer((_) async => const PublishedPackageInfo());
    });

    tearDown(() {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    test('should pass when real files reference the version', () async {
      File('${tempDir.path}/$pkgPath/CHANGELOG.md').writeAsStringSync(
        '# Changelog\n\n## [1.0.0]\n- Initial release.',
      );
      File('${tempDir.path}/$pkgPath/README.md').writeAsStringSync(
        'foo-1.0.0\n\nInstall with `foo: ^1.0.0`.',
      );

      await expectLater(
        buildRealFilesSut()('${tempDir.path}/$pkgPath'),
        completes,
      );
    });

    test('should flag near-miss references as incomplete', () async {
      File('${tempDir.path}/$pkgPath/CHANGELOG.md').writeAsStringSync(
        '# Changelog\n\n## 1.0.0-rc.1\n',
      );
      File('${tempDir.path}/$pkgPath/README.md').writeAsStringSync(
        'foo-1.0.0-1\n\nInstall with `foo: ^0.9.0`.',
      );

      final issues = await buildRealFilesSut()('${tempDir.path}/$pkgPath');

      expect(
        issues.map((i) => i.issueMessage),
        containsAll([
          'CHANGELOG.md has no entry for 1.0.0.',
          'README.md does not reference foo-1.0.0 (git install).',
          'README.md does not reference foo: ^1.0.0 (registry install).',
        ]),
      );
    });
  });
}
