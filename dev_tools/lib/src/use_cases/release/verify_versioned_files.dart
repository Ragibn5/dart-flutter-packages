import 'dart:io';

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
/// The checks to run are fully injected via `checks`; no
/// checks are added implicitly.
class VerifyVersionedFiles {
  const VerifyVersionedFiles();

  /// Collects problems for files that do not reference the new version.
  ///
  /// Params:
  /// - `packagePath`: absolute path to the package directory.
  /// - `name`: package name.
  /// - `version`: package version, as read from the pubspec.
  /// - `checks`: the complete set of checks to run; each
  ///   check's pattern must match its file for the release to be complete.
  ///
  /// Returns: a list of problem descriptions, empty when every file exists
  /// and references [version]; a missing file is reported as its own
  /// problem rather than throwing.
  Future<List<String>> call({
    required String packagePath,
    required String name,
    required String version,
    required Map<String, VersionedFileCheck> checks,
  }) async {
    final problems = <String>[];
    for (final entry in checks.entries) {
      final check = entry.value;
      final file = File('$packagePath/${check.filePath}');
      if (!file.existsSync()) {
        problems.add('${check.filePath} is missing.');
        continue;
      }

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
}
