import 'dart:io';

import 'package:dev_tools/dev_tools.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('project_utils_test');
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  group('findProjectRoot', () {
    test('returns the directory containing pubspec.yaml', () async {
      final nested = Directory('${tempDir.path}/a/b/c')
        ..createSync(recursive: true);
      File('${tempDir.path}/pubspec.yaml').writeAsStringSync('name: foo\n');

      final root = await const ProjectUtils().findProjectRoot(nested.path);
      expect(root, tempDir.path);
    });

    test('throws when no pubspec.yaml exists upward', () async {
      final empty = Directory('${tempDir.path}/a/b')
        ..createSync(recursive: true);
      await expectLater(
        const ProjectUtils().findProjectRoot(empty.path),
        throwsA(isA<ProjectRootNotFoundException>()),
      );
    });
  });

  group('getCurrentDartPackage', () {
    test('reads name field from pubspec.yaml', () async {
      File(
        '${tempDir.path}/pubspec.yaml',
      ).writeAsStringSync('name: my_package\nversion: 1.0.0\n');
      expect(
        await const ProjectUtils().getCurrentDartPackage(tempDir.path),
        'my_package',
      );
    });
  });

  group('getCurrentPlatformPackage', () {
    test('reads applicationId from build.gradle.kts', () async {
      final androidApp = Directory('${tempDir.path}/android/app')
        ..createSync(recursive: true);
      File('${androidApp.path}/build.gradle.kts').writeAsStringSync(
        'android {\n'
        '  defaultConfig {\n'
        '    applicationId = "org.example.app"\n'
        '  }\n'
        '}\n',
      );

      expect(
        await const ProjectUtils().getCurrentPlatformPackage(tempDir.path),
        'org.example.app',
      );
    });
  });
}
