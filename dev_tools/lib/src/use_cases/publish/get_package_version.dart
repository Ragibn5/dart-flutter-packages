import 'dart:io';

class GetPackageVersion {
  const GetPackageVersion();

  Future<String?> call(String repoRoot, String pkgPath) async {
    final file = File('$repoRoot/$pkgPath/pubspec.yaml');
    return _readYamlField(file, 'version');
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
