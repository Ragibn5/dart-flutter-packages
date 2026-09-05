import 'dart:io';

class GetPackageName {
  const GetPackageName();

  /// Reads the package name from a pubspec.yaml file.
  ///
  /// Params:
  /// - `repoRoot`: absolute path to the repository root.
  /// - `pkgPath`: package directory relative to [repoRoot].
  ///
  /// Returns: the package name, or null when the file is missing.
  Future<String?> call(String repoRoot, String pkgPath) {
    final file = File('$repoRoot/$pkgPath/pubspec.yaml');
    return _readYamlField(file, 'name');
  }

  Future<String?> _readYamlField(File file, String field) async {
    if (!file.existsSync()) return null;
    final lines = await file.readAsLines();
    for (final line in lines) {
      if (!line.startsWith('$field:')) continue;
      return line
          .substring('$field:'.length)
          .trim()
          .replaceAll('"', '')
          .replaceAll("'", '')
          .replaceAll(RegExp(r'\s'), '');
    }
    return null;
  }
}
