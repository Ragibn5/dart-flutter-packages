import 'dart:io';

import 'package:dev_tools/src/use_cases/dart_flutter/find_project_root.dart';

class GetCurrentPlatformPackage {
  const GetCurrentPlatformPackage();

  /// Reads the Android applicationId of the current platform package.
  ///
  /// Params:
  /// - `projectRoot`: absolute path to the project root (default: the
  ///   project root resolved from the current directory).
  ///
  /// Returns: the applicationId, or null when build.gradle.kts is missing.
  ///
  /// Throws:
  /// - [ProjectRootNotFoundException] when `projectRoot` is omitted and no
  ///   project root can be found.
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
