import 'dart:io';

import 'package:dev_tools/src/dev_tools_exception.dart';

/// Utilities for locating a project and reading its package metadata.
///
/// Mirrors `project_utils.sh`.
class ProjectUtils {
  const ProjectUtils();

  /// Finds the nearest directory (starting from [start]) that contains a
  /// `pubspec.yaml`, walking upward to the filesystem root.
  ///
  /// Throws [ProjectRootNotFoundException] if no project root is found.
  Future<String> findProjectRoot([String? start]) async {
    final dir = Directory(start ?? Directory.current.path).absolute;
    var current = dir;
    while (current.path != current.parent.path) {
      if (File('${current.path}/pubspec.yaml').existsSync()) {
        return current.path;
      }
      current = current.parent;
    }
    throw ProjectRootNotFoundException(
      'Error: could not find project root from ${dir.path}.',
    );
  }

  /// Reads the `name:` field from `pubspec.yaml` in [projectRoot].
  ///
  /// Returns `null` if no name is present.
  Future<String?> getCurrentDartPackage([String? projectRoot]) async {
    final root = projectRoot ?? await findProjectRoot();
    final pubspec = File('$root/pubspec.yaml');
    if (!pubspec.existsSync()) return null;
    return _readYamlField(pubspec, 'name');
  }

  /// Reads the `applicationId` from the Android `build.gradle.kts` in
  /// [projectRoot].
  ///
  /// The Android package name and iOS bundle ID are assumed to be identical;
  /// other tooling relies on this assumption.
  ///
  /// Returns `null` if none is present.
  Future<String?> getCurrentPlatformPackage([String? projectRoot]) async {
    final root = projectRoot ?? await findProjectRoot();
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

  Future<String?> _readYamlField(File file, String field) async {
    final lines = await file.readAsLines();
    for (final line in lines) {
      if (!line.startsWith('$field:')) continue;
      final value = line.substring('$field:'.length).trim();
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

/// Thrown when no project root (directory with a `pubspec.yaml`) is found.
class ProjectRootNotFoundException extends DevToolsException {
  const ProjectRootNotFoundException(super.message);
}
