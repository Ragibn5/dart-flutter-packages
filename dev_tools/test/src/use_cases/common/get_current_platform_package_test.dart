import 'dart:io';

import 'package:dev_tools/src/use_cases/common/get_current_platform_package.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;

  late GetCurrentPlatformPackage sut;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('get_platform_package_test');

    sut = const GetCurrentPlatformPackage();
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test(
    'should return applicationId when build.gradle.kts contains it',
    () async {
      final androidApp = Directory('${tempDir.path}/android/app')
        ..createSync(recursive: true);
      File('${androidApp.path}/build.gradle.kts').writeAsStringSync(
        'android {\n'
        '  defaultConfig {\n'
        '    applicationId = "org.example.app"\n'
        '  }\n'
        '}\n',
      );

      expect(await sut(tempDir.path), 'org.example.app');
    },
  );

  test('should return null when build.gradle.kts does not exist', () async {
    expect(await sut(tempDir.path), isNull);
  });
}
