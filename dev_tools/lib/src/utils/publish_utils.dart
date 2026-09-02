import 'dart:io';

import 'package:dev_tools/src/dev_tools_exception.dart';
import 'package:dev_tools/src/utils/git_utils.dart';
import 'package:dev_tools/src/utils/project_utils.dart';
import 'package:dev_tools/src/utils/prompt_utils.dart';

/// Utilities for validating and publishing a package to pub.dev.
///
/// Mirrors `publish.sh` and `publish_utils.sh`.
class PublishUtils {
  final GitUtils _gitUtils;
  final ProjectUtils _projectUtils;
  final PromptUtils _promptUtils;

  const PublishUtils({
    GitUtils gitUtils = const GitUtils(),
    ProjectUtils projectUtils = const ProjectUtils(),
    PromptUtils promptUtils = const PromptUtils(),
  }) : _gitUtils = gitUtils,
       _projectUtils = projectUtils,
       _promptUtils = promptUtils;

  /// Validates that [pkgPath] exists and contains a `pubspec.yaml` inside
  /// [repoRoot].
  ///
  /// Throws [PublishValidationException] when invalid.
  void validatePackagePath(String repoRoot, String pkgPath) {
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

  /// Reads the package `name` from `pubspec.yaml` at [pkgPath] in [repoRoot].
  Future<String?> getPackageName(String repoRoot, String pkgPath) {
    return _projectUtils.getCurrentDartPackage('$repoRoot/$pkgPath');
  }

  /// Reads the package `version` from `pubspec.yaml` at [pkgPath] in
  /// [repoRoot], or `null` when absent.
  Future<String?> getPackageVersion(String repoRoot, String pkgPath) async {
    final file = File('$repoRoot/$pkgPath/pubspec.yaml');
    if (!file.existsSync()) return null;
    final lines = await file.readAsLines();
    for (final line in lines) {
      if (!line.startsWith('version:')) continue;
      return line
          .substring('version:'.length)
          .trim()
          .replaceAll('"', '')
          .replaceAll("'", '')
          .replaceAll(RegExp(r'\s'), '');
    }
    return null;
  }

  /// Runs the full pre-flight + dry-run + publish flow.
  ///
  /// Validates the current release branch, matches the branch version against
  /// the pubspec version, warns on a dirty working tree, dry-runs, then — when
  /// [dryRunOnly] is `false` — confirms and publishes.
  ///
  /// Throws a [DevToolsException] when the flow cannot proceed, and returns
  /// normally (without publishing) when the user cancels.
  Future<void> runPublishFlow({
    required String repoRoot,
    bool dryRunOnly = false,
  }) async {
    final branch = await _gitUtils.currentBranch(repoRoot);
    if (branch == null) {
      throw const PublishValidationException(
        'Error: Detached HEAD. Checkout a release branch first.',
      );
    }
    final parsed = _gitUtils.parseReleaseBranch(branch);
    if (parsed == null) {
      throw const PublishValidationException(
        'Error: Branch name does not match format release/<package-path>-<version>.',
      );
    }

    final pkgPath = parsed.packagePath;
    validatePackagePath(repoRoot, pkgPath);

    final pkgName = await getPackageName(repoRoot, pkgPath);
    final pkgVersion = await getPackageVersion(repoRoot, pkgPath);

    stdout
      ..writeln('  Package: $pkgName')
      ..writeln('  Version: $pkgVersion')
      ..writeln('  Branch:  $branch');

    if (parsed.version != pkgVersion) {
      throw PublishValidationException(
        'Error: Version mismatch — branch says ${parsed.version}, '
        'pubspec says $pkgVersion.',
      );
    }

    var warnings = false;
    if (!await _gitUtils.hasCleanWorkingTree(repoRoot)) {
      stdout.writeln('  WARNING: You have uncommitted changes.');
      warnings = true;
    }

    if (warnings &&
        !await _promptUtils.confirmYesNo('Continue despite warnings?')) {
      stdout.writeln('Cancelled.');
      return;
    }

    stdout.writeln('\nDRY-RUN PUBLISH');
    final dryExit = await _publish(repoRoot, pkgPath, dryRun: true);
    stdout.writeln('DRY-RUN COMPLETE\n');
    if (dryExit != 0) {
      throw const PublishFailedException(
        'Error: Dry-run failed. Fix issues before publishing.',
      );
    }

    if (dryRunOnly) {
      stdout.writeln('Dry-run complete. Skipping actual publish.');
      return;
    }

    final confirmed = await _promptUtils.confirmYesNo(
      'Publish $pkgName@$pkgVersion?',
    );
    if (!confirmed) {
      stdout.writeln('Cancelled.');
      return;
    }

    stdout.writeln('\nPUBLISHING');
    final exitCode = await _publish(repoRoot, pkgPath, dryRun: false);
    if (exitCode != 0) {
      throw const PublishFailedException('Error: Publishing failed.');
    }
    stdout.writeln('Successfully published!');
  }

  Future<int> _publish(
    String repoRoot,
    String pkgPath, {
    required bool dryRun,
  }) async {
    final args = ['pub', 'publish'];
    if (dryRun) args.add('--dry-run');
    final result = await Process.run(
      'dart',
      args,
      workingDirectory: '$repoRoot/$pkgPath',
    );
    stdout.write(result.stdout);
    stderr.write(result.stderr);
    return result.exitCode;
  }
}

/// Thrown when a package path fails validation.
class PublishValidationException extends DevToolsException {
  const PublishValidationException(super.message);
}

/// Thrown when publishing (or its dry-run) fails.
class PublishFailedException extends DevToolsException {
  const PublishFailedException(super.message);
}
