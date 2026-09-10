import 'dart:io';

import 'package:dev_tools/src/models/local_package_info.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_packages.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;

  late FindPackages sut;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('find_packages_test');
    sut = const FindPackages();
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  void writePubspec(String relativeDir, String content) {
    final dir = Directory('${tempDir.path}/$relativeDir')
      ..createSync(recursive: true);
    File('${dir.path}/pubspec.yaml').writeAsStringSync(content);
  }

  test('should find every package with a readable pubspec', () async {
    writePubspec('pkg_a', 'name: pkg_a\nversion: 1.0.0\n');
    writePubspec('nested/pkg_b', 'name: pkg_b\nversion: 2.0.0\n');

    final packages = await sut(
      repoRoot: tempDir.path,
      filter: (_) => true,
    );

    expect(
      packages.map((p) => p.packageIdentity.name),
      containsAll(['pkg_a', 'pkg_b']),
    );
  });

  test(
      'should skip a package whose pubspec has no version instead of '
      'throwing', () async {
    writePubspec('pkg_a', 'name: pkg_a\nversion: 1.0.0\n');
    writePubspec('unversioned', 'name: unversioned\npublish_to: none\n');

    final packages = await sut(
      repoRoot: tempDir.path,
      filter: (_) => true,
    );

    expect(packages.map((p) => p.packageIdentity.name), ['pkg_a']);
  });

  test('should apply filter only to packages with a readable pubspec',
      () async {
    writePubspec('pkg_a', 'name: pkg_a\nversion: 1.0.0\n');
    writePubspec('unversioned', 'name: unversioned\n');

    final packages = await sut(
      repoRoot: tempDir.path,
      filter: (LocalPackageInfo info) => info.packageIdentity.name.isNotEmpty,
    );

    expect(packages, hasLength(1));
    expect(packages.single.packageIdentity.name, 'pkg_a');
  });

  test('should throw PackageFinderException when repoRoot does not exist',
      () async {
    expect(
      () => sut(repoRoot: '${tempDir.path}/missing', filter: (_) => true),
      throwsA(isA<PackageFinderException>()),
    );
  });
}
