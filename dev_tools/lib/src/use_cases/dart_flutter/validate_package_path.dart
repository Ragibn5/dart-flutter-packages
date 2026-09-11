import 'dart:io';

import 'package:dev_tools/src/use_cases/publish/publish_validation_exception.dart';

class ValidatePackagePath {
  const ValidatePackagePath();

  /// Validates that a path points to a valid Flutter/Dart package directory.
  ///
  /// Params:
  /// - `packagePath`: absolute path to the package directory.
  ///
  /// Returns: nothing (void).
  ///
  /// Throws:
  /// - [PublishValidationException] when the directory or its pubspec.yaml
  ///   is missing.
  void call(String packagePath) {
    final full = Directory(packagePath);
    if (!full.existsSync()) {
      throw PublishValidationException(
        "Error: Directory '$packagePath' not found.",
      );
    }
    if (!File('${full.path}/pubspec.yaml').existsSync()) {
      throw PublishValidationException(
        "Error: No pubspec.yaml found in '$packagePath'.",
      );
    }
  }
}
