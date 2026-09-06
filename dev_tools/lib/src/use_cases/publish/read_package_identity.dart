import 'dart:io';

import 'package:dev_tools/src/exceptions/command_execution_exception.dart';
import 'package:dev_tools/src/models/package_identity.dart';
import 'package:yaml/yaml.dart';

/// Represents an exception related to a package's malformed or
/// missing identity.
class PackageIdentityException extends CommandExecutionException {
  @override
  final String message;

  const PackageIdentityException(this.message);
}

class ReadPackageIdentity {
  const ReadPackageIdentity();

  /// Reads the package identity.
  ///
  /// Params:
  /// - `repoRoot`: absolute path to the repository root.
  /// - `pkgPath`: package directory relative to [repoRoot].
  ///
  /// Returns: a [PackageIdentity].
  ///
  /// Notes: throws [PackageIdentityException] when the pubspec is
  /// missing or lacks a `name` or `version`.
  Future<PackageIdentity> call(
    String repoRoot,
    String pkgPath,
  ) async {
    final pubspecFile = File('$repoRoot/$pkgPath/pubspec.yaml');
    if (!pubspecFile.existsSync()) {
      throw const PackageIdentityException(
        'Error: pubspec.yaml not found.',
      );
    }

    final pubspec = loadYaml(await pubspecFile.readAsString());
    final map = pubspec as YamlMap;
    final name = map['name']?.toString().trim() ?? '';
    final version = map['version']?.toString().trim() ?? '';
    if (name.isEmpty) {
      throw const PackageIdentityException(
        'Error: pubspec.yaml has no name.',
      );
    }
    if (version.isEmpty) {
      throw const PackageIdentityException(
        'Error: pubspec.yaml has no version.',
      );
    }
    final isFlutterPackage = map.containsKey('flutter') ||
        _flutterSdkReferenced(map, 'environment') ||
        _flutterSdkReferenced(map, 'dependencies') ||
        _flutterSdkReferenced(map, 'dev_dependencies');
    return PackageIdentity(
      name: name,
      version: version,
      isFlutterPackage: isFlutterPackage,
    );
  }

  static bool _flutterSdkReferenced(YamlMap map, String key) =>
      map[key] is YamlMap && (map[key] as YamlMap).containsKey('flutter');
}
