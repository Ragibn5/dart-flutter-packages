import 'dart:io';

import 'package:dev_tools/src/use_cases/publish_validation_exception.dart';

class ValidatePackagePath {
  const ValidatePackagePath();

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
