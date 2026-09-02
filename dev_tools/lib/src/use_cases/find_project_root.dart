import 'dart:io';

class FindProjectRoot {
  const FindProjectRoot();

  Future<String> call([String? start]) async {
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
}

class ProjectRootNotFoundException implements Exception {
  final String message;

  const ProjectRootNotFoundException(this.message);
}
