import 'dart:io';

import 'package:dev_tools/src/models/package_identity.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/parse_pubspec_content.dart';

export 'package:dev_tools/src/use_cases/dart_flutter/parse_pubspec_content.dart'
    show PackageIdentityException;

class ReadPackageIdentity {
  final ParsePubspecContent _parsePubspecContent;

  const ReadPackageIdentity({
    ParsePubspecContent parsePubspecContent = const ParsePubspecContent(),
  }) : _parsePubspecContent = parsePubspecContent;

  /// Reads the package identity.
  ///
  /// Params:
  /// - `packagePath`: absolute path to the package directory.
  ///
  /// Returns: a [PackageIdentity].
  ///
  /// Throws:
  /// - [PackageIdentityException] when the pubspec is missing or lacks a
  ///   `name` or `version`.
  Future<PackageIdentity> call(String packagePath) async {
    final pubspecFile = File('$packagePath/pubspec.yaml');
    if (!pubspecFile.existsSync()) {
      throw const PackageIdentityException('Error: pubspec.yaml not found.');
    }

    return _parsePubspecContent(await pubspecFile.readAsString());
  }
}
