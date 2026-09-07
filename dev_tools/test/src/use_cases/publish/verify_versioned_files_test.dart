import 'dart:io';

import 'package:dev_tools/src/use_cases/publish/verify_versioned_files.dart';
import 'package:test/test.dart';

RegExp _containsVersionPattern(String name, String version) =>
    RegExp(RegExp.escape(version));

String _versionProblem(String name, String version) =>
    'VERSION.txt lacks $version.';

RegExp _headingPattern(String name, String version) =>
    RegExp('^## ${RegExp.escape(version)}');

RegExp _nameVersionPattern(String name, String version) =>
    RegExp(RegExp.escape('$name-$version'));

String _noteProblem(String name, String version) => 'NOTE.txt lacks $version.';

String _changelogProblem(String name, String version) =>
    'CHANGELOG.md lacks $version.';

String _installProblem(String name, String version) =>
    'docs/install.md lacks $name-$version.';

void main() {
  const pkgPath = 'pkg';

  late Directory tempDir;

  late VerifyVersionedFiles sut;

  setUp(() {
    tempDir =
        Directory.systemTemp.createTempSync('verify_versioned_files_test');
    Directory('${tempDir.path}/$pkgPath').createSync(recursive: true);

    sut = const VerifyVersionedFiles();
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  const versionFileChecks = <String, VersionedFileCheck>{
    'version': VersionedFileCheck(
      filePath: 'VERSION.txt',
      pattern: _containsVersionPattern,
      problem: _versionProblem,
    ),
  };

  test('should return no problems when every file references the version',
      () async {
    File('${tempDir.path}/$pkgPath/VERSION.txt').writeAsStringSync('2.0.0\n');

    final problems = await sut(
      packagePath: '${tempDir.path}/$pkgPath',
      name: 'foo',
      version: '2.0.0',
      requiredVersionedFiles: versionFileChecks,
    );

    expect(problems, isEmpty);
  });

  test('should report a problem when a file does not reference the version',
      () async {
    File('${tempDir.path}/$pkgPath/VERSION.txt').writeAsStringSync('1.0.0\n');

    final problems = await sut(
      packagePath: '${tempDir.path}/$pkgPath',
      name: 'foo',
      version: '2.0.0',
      requiredVersionedFiles: versionFileChecks,
    );

    expect(problems, <String>['VERSION.txt lacks 2.0.0.']);
  });

  test('should report a problem for each file that lacks the version',
      () async {
    File('${tempDir.path}/$pkgPath/VERSION.txt').writeAsStringSync('2.0.0\n');
    File('${tempDir.path}/$pkgPath/NOTE.txt').writeAsStringSync('old\n');

    const checks = <String, VersionedFileCheck>{
      ...versionFileChecks,
      'note': VersionedFileCheck(
        filePath: 'NOTE.txt',
        pattern: _containsVersionPattern,
        problem: _noteProblem,
      ),
    };

    final problems = await sut(
      packagePath: '${tempDir.path}/$pkgPath',
      name: 'foo',
      version: '2.0.0',
      requiredVersionedFiles: checks,
    );

    expect(problems, <String>['NOTE.txt lacks 2.0.0.']);
  });

  test(
    'should throw VersionedFileVerificationException when a checked file '
    'is missing',
    () async {
      await expectLater(
        sut(
          packagePath: '${tempDir.path}/$pkgPath',
          name: 'foo',
          version: '2.0.0',
          requiredVersionedFiles: versionFileChecks,
        ),
        throwsA(
          isA<VersionedFileVerificationException>().having(
            (e) => e.message,
            'message',
            'Error: VERSION.txt is missing.',
          ),
        ),
      );
    },
  );

  test('should support files in subdirectories of the package', () async {
    final docsDir = Directory('${tempDir.path}/$pkgPath/docs')
      ..createSync(recursive: true);
    File('${docsDir.path}/install.md').writeAsStringSync('foo-2.0.0\n');

    const checks = <String, VersionedFileCheck>{
      'install': VersionedFileCheck(
        filePath: 'docs/install.md',
        pattern: _nameVersionPattern,
        problem: _installProblem,
      ),
    };

    final problems = await sut(
      packagePath: '${tempDir.path}/$pkgPath',
      name: 'foo',
      version: '2.0.0',
      requiredVersionedFiles: checks,
    );

    expect(problems, isEmpty);
  });

  test('should match per-line anchored patterns when multiLine is enabled',
      () async {
    File('${tempDir.path}/$pkgPath/CHANGELOG.md')
        .writeAsStringSync('# Changelog\n\n## 2.0.0\n');

    const checks = <String, VersionedFileCheck>{
      'changelog': VersionedFileCheck(
        filePath: 'CHANGELOG.md',
        pattern: _headingPattern,
        problem: _changelogProblem,
        multiLine: true,
      ),
    };

    final problems = await sut(
      packagePath: '${tempDir.path}/$pkgPath',
      name: 'foo',
      version: '2.0.0',
      requiredVersionedFiles: checks,
    );

    expect(problems, isEmpty);
  });
}
