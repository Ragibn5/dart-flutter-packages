import 'dart:io';

import 'package:dev_tools/src/use_cases/common/find_project_root.dart';

class GetCurrentPlatformPackage {
  const GetCurrentPlatformPackage();

  Future<String?> call([String? projectRoot]) async {
    final root = projectRoot ?? await const FindProjectRoot()();
    final gradle = File('$root/android/app/build.gradle.kts');
    if (!gradle.existsSync()) return null;
    final lines = await gradle.readAsLines();
    for (final line in lines) {
      final trimmed = line.trimLeft();
      if (!trimmed.startsWith('applicationId = ')) continue;
      final value = trimmed.substring('applicationId = '.length).trim();
      return _stripQuotesAndWhitespace(value);
    }
    return null;
  }

  String _stripQuotesAndWhitespace(String value) {
    return value
        .replaceAll('"', '')
        .replaceAll("'", '')
        .replaceAll(RegExp(r'\s'), '');
  }
}
