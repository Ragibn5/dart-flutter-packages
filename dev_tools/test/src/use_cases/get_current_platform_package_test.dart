import 'dart:io';

import 'package:dev_tools/src/use_cases/get_current_platform_package.dart';
import 'package:test/test.dart';

void main() {
  const useCase = GetCurrentPlatformPackage();
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('get_platform_package_test');
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

      expect(await useCase(tempDir.path), 'org.example.app');
    },
  );

  test('should return null when build.gradle.kts does not exist', () async {
    expect(await useCase(tempDir.path), isNull);
  });
}
