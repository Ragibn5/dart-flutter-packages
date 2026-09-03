import 'dart:io';

import 'package:dev_tools/src/use_cases/publish_validation_exception.dart';
import 'package:dev_tools/src/use_cases/validate_package_path.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;

  late ValidatePackagePath sut;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('validate_package_path_test');

    sut = const ValidatePackagePath();
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('should pass when package directory contains a pubspec.yaml', () {
    Directory('${tempDir.path}/pkg').createSync();
    File('${tempDir.path}/pkg/pubspec.yaml').writeAsStringSync('name: p\n');

    expect(() => sut(tempDir.path, 'pkg'), returnsNormally);
  });

  test(
    'should throw PublishValidationException when directory does not exist',
    () {
      expect(
        () => sut(tempDir.path, 'nope'),
        throwsA(isA<PublishValidationException>()),
      );
    },
  );

  test(
    // ignore: lines_longer_than_80_chars
    'should throw PublishValidationException when directory has no pubspec.yaml',
    () {
      Directory('${tempDir.path}/empty').createSync();

      expect(
        () => sut(tempDir.path, 'empty'),
        throwsA(isA<PublishValidationException>()),
      );
    },
  );
}
