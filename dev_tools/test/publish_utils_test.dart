import 'dart:io';

import 'package:dev_tools/dev_tools.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;

  setUp(() => tempDir = Directory.systemTemp.createTempSync('publish_test'));

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  group('getPackageVersion', () {
    test('reads version from pubspec.yaml', () async {
      File(
        '${tempDir.path}/pubspec.yaml',
      ).writeAsStringSync('name: foo\nversion: 2.1.0\n');
      expect(
        await const PublishUtils().getPackageVersion(tempDir.path, '.'),
        '2.1.0',
      );
    });
  });

  group('validatePackagePath', () {
    test('accepts a package directory with pubspec.yaml', () async {
      Directory('${tempDir.path}/pkg').createSync();
      File('${tempDir.path}/pkg/pubspec.yaml').writeAsStringSync('name: p\n');
      expect(
        () => const PublishUtils().validatePackagePath(tempDir.path, 'pkg'),
        returnsNormally,
      );
    });

    test('rejects a missing directory', () {
      expect(
        () => const PublishUtils().validatePackagePath(tempDir.path, 'nope'),
        throwsA(isA<PublishValidationException>()),
      );
    });
  });
}
