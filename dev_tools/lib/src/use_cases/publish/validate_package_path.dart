import 'dart:io';

import 'package:dev_tools/src/use_cases/publish/publish_validation_exception.dart';

class ValidatePackagePath {
  const ValidatePackagePath();

  /// Validates that a path points to a package directory.
  ///
  /// Params:
  /// - `repoRoot`: absolute path to the repository root.
  /// - `pkgPath`: package directory relative to [repoRoot].
  ///
  /// Returns: nothing (void) when the path is valid.
  ///
  /// Notes: throws [PublishValidationException] when the directory or its
  /// pubspec.yaml is missing.
  void call(String repoRoot, String pkgPath) {
    final full = Directory('$repoRoot/$pkgPath');
    if (!full.existsSync()) {
      throw PublishValidationException(
        "Error: Directory '$pkgPath' not found.",
      );
    }
    if (!File('${full.path}/pubspec.yaml').existsSync()) {
      throw PublishValidationException(
        "Error: No pubspec.yaml found in '$pkgPath'.",
      );
    }
  }
}
