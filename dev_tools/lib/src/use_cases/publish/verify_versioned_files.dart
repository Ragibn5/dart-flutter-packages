import 'dart:io';

import 'package:dev_tools/src/exceptions/command_execution_exception.dart';

/// Represents an exception when a file does not contain expected version info.
class VersionedFileVerificationException extends CommandExecutionException {
  @override
  final String message;

  const VersionedFileVerificationException(this.message);
}

/// A single check that a file references the new version.
class VersionedFileCheck {
  /// Path of the file to check, relative to the package directory; may
  /// include subdirectories.
  final String filePath;

  /// Builds the pattern that proves the file references the version.
  final RegExp Function(String name, String version) pattern;

  /// Builds the problem description for the given package `name` and
  /// `version` when the pattern does not match.
  final String Function(String name, String version) problem;

  /// Whether the pattern spans lines (e.g. per-line anchored matches).
  final bool multiLine;

  const VersionedFileCheck({
    required this.filePath,
    required this.pattern,
    required this.problem,
    this.multiLine = false,
  });
}

/// Verifies that a package's files reference the new version.
///
/// The checks to run are fully injected via `requiredVersionedFiles`; no
/// checks are added implicitly.
class VerifyVersionedFiles {
  const VerifyVersionedFiles();

  /// Collects problems for files that do not reference the new version.
  ///
  /// Params:
  /// - `packagePath`: absolute path to the package directory.
  /// - `name`: package name.
  /// - `version`: package version, as read from the pubspec.
  /// - `requiredVersionedFiles`: the complete set of checks to run; each
  ///   check's pattern must match its file for the release to be complete.
  ///
  /// Returns: a list of problem descriptions, empty when every file
  /// references [version].
  Future<List<String>> call({
    required String packagePath,
    required String name,
    required String version,
    required Map<String, VersionedFileCheck> requiredVersionedFiles,
  }) async {
    final problems = <String>[];
    for (final entry in requiredVersionedFiles.entries) {
      final check = entry.value;
      final file = File('$packagePath/${check.filePath}');
      _requireExists(file, check.filePath);

      final pattern = check.pattern(name, version);
      final regex =
          check.multiLine ? RegExp(pattern.pattern, multiLine: true) : pattern;
      final content = await file.readAsString();
      if (!regex.hasMatch(content)) {
        problems.add(check.problem(name, version));
      }
    }

    return problems;
  }

  void _requireExists(File file, String relPath) {
    if (!file.existsSync()) {
      throw VersionedFileVerificationException(
        'Error: $relPath is missing.',
      );
    }
  }
}
