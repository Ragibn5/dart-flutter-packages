import 'dart:io';

import 'package:dev_tools/src/use_cases/common/find_project_root.dart';

class GetCurrentDartPackage {
  const GetCurrentDartPackage();

  Future<String?> call([String? projectRoot]) async {
    final root = projectRoot ?? await const FindProjectRoot()();
    final pubspecFile = File('$root/pubspec.yaml');
    if (!pubspecFile.existsSync()) {
      return null;
    }
    return _readYamlField(pubspecFile, 'name');
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
