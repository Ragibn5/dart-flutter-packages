import 'dart:io';

import 'package:dev_tools/src/use_cases/publish/get_package_version.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;

  late GetPackageVersion sut;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('get_package_version_test');

    sut = const GetPackageVersion();
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('should return version when pubspec.yaml has a version field', () async {
    File(
      '${tempDir.path}/pubspec.yaml',
    ).writeAsStringSync('name: foo\nversion: 2.1.0\n');

    expect(await sut(tempDir.path, '.'), '2.1.0');
  });

  test('should return null when pubspec.yaml does not exist', () async {
    expect(await sut(tempDir.path, '.'), isNull);
  });

  test('should return null when pubspec.yaml has no version field', () async {
    File('${tempDir.path}/pubspec.yaml').writeAsStringSync('name: foo\n');

    expect(await sut(tempDir.path, '.'), isNull);
  });
}
