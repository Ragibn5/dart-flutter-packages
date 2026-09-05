// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:dev_tools/src/use_cases/common/find_project_root.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;

  late FindProjectRoot sut;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('find_project_root_test');

    sut = const FindProjectRoot();
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

      final root = await sut(nested.path);
      expect(root, tempDir.path);
    },
  );

  test(
    'should return the given directory when it contains pubspec.yaml',
    () async {
      File('${tempDir.path}/pubspec.yaml').writeAsStringSync('name: foo\n');

      final root = await sut(tempDir.path);
      expect(root, tempDir.path);
    },
  );

  test(
    'should throw ProjectRootNotFoundException when no pubspec.yaml exists upward',
    () async {
      final empty = Directory('${tempDir.path}/a/b')
        ..createSync(recursive: true);

      expect(
        () => sut(empty.path),
        throwsA(isA<ProjectRootNotFoundException>()),
      );
    },
  );
}
