import 'dart:io';

import 'package:dev_tools/src/use_cases/find_project_root.dart';
import 'package:test/test.dart';

void main() {
  const useCase = FindProjectRoot();
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('find_project_root_test');
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test(
    'should return the nearest ancestor with pubspec.yaml when starting from a nested path',
    () async {
      final nested = Directory('${tempDir.path}/a/b/c')
        ..createSync(recursive: true);
      File('${tempDir.path}/pubspec.yaml').writeAsStringSync('name: foo\n');

      final root = await useCase(nested.path);
      expect(root, tempDir.path);
    },
  );

  test(
    'should return the given directory when it contains pubspec.yaml',
    () async {
      File('${tempDir.path}/pubspec.yaml').writeAsStringSync('name: foo\n');

      final root = await useCase(tempDir.path);
      expect(root, tempDir.path);
    },
  );

  test(
    'should throw ProjectRootNotFoundException when no pubspec.yaml exists upward',
    () async {
      final empty = Directory('${tempDir.path}/a/b')
        ..createSync(recursive: true);

      expect(
        () => useCase(empty.path),
        throwsA(isA<ProjectRootNotFoundException>()),
      );
    },
  );
}
