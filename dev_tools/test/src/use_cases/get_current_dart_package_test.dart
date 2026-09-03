import 'dart:io';

import 'package:dev_tools/src/use_cases/get_current_dart_package.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;

  late GetCurrentDartPackage sut;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('get_dart_package_test');

    sut = const GetCurrentDartPackage();
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test(
    'should return package name when pubspec.yaml has a name field',
    () async {
      File(
        '${tempDir.path}/pubspec.yaml',
      ).writeAsStringSync('name: my_package\nversion: 1.0.0\n');

      expect(await sut(tempDir.path), 'my_package');
    },
  );

  test('should return null when pubspec.yaml does not exist', () async {
    expect(await sut(tempDir.path), isNull);
  });

  test('should return null when pubspec.yaml has no name field', () async {
    File('${tempDir.path}/pubspec.yaml').writeAsStringSync('version: 1.0.0\n');

    expect(await sut(tempDir.path), isNull);
  });
}
