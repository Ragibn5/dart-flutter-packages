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

class ParsePubspecContent {
  const ParsePubspecContent();

  /// Parses a package identity out of pubspec.yaml content.
  ///
  /// Params:
  /// - `pubspecContent`: the raw contents of a pubspec.yaml file.
  ///
  /// Returns: a [PackageIdentity].
  ///
  /// Notes: throws [PackageIdentityException] when the content lacks a
  /// `name` or `version`.
  PackageIdentity call(String pubspecContent) {
    final pubspec = loadYaml(pubspecContent);
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
    final publishTo = map['publish_to']?.toString().trim();
    return PackageIdentity(
      name: name,
      version: version,
      isFlutterPackage: isFlutterPackage,
      isPublishable: publishTo != 'none',
    );
  }

  static bool _flutterSdkReferenced(YamlMap map, String key) =>
      map[key] is YamlMap && (map[key] as YamlMap).containsKey('flutter');
}
