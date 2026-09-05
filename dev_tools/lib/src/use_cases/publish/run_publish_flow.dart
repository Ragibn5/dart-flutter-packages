import 'dart:io';

import 'package:dev_tools/src/use_cases/common/confirm_yes_no.dart';
import 'package:dev_tools/src/use_cases/git/get_current_branch.dart';
import 'package:dev_tools/src/use_cases/git/has_clean_working_tree.dart';
import 'package:dev_tools/src/use_cases/publish/get_package_name.dart';
import 'package:dev_tools/src/use_cases/publish/get_package_version.dart';
import 'package:dev_tools/src/use_cases/publish/parse_release_branch.dart';
import 'package:dev_tools/src/use_cases/publish/publish_validation_exception.dart';
import 'package:dev_tools/src/use_cases/publish/validate_package_path.dart';

typedef PublishProcessRunner = Future<int> Function(
  String repoRoot,
  String pkgPath, {
  required bool dryRun,
});

class RunPublishFlow {
  final GetCurrentBranch _getCurrentBranch;
  final ParseReleaseBranch _parseReleaseBranch;
  final HasCleanWorkingTree _hasCleanWorkingTree;
  final ValidatePackagePath _validatePackagePath;
  final GetPackageName _getPackageName;
  final GetPackageVersion _getPackageVersion;
  final ConfirmYesNo _confirmYesNo;
  final PublishProcessRunner? _publish;

  const RunPublishFlow({
    GetCurrentBranch getCurrentBranch = const GetCurrentBranch(),
    ParseReleaseBranch parseReleaseBranch = const ParseReleaseBranch(),
    HasCleanWorkingTree hasCleanWorkingTree = const HasCleanWorkingTree(),
    ValidatePackagePath validatePackagePath = const ValidatePackagePath(),
    GetPackageName getPackageName = const GetPackageName(),
    GetPackageVersion getPackageVersion = const GetPackageVersion(),
    ConfirmYesNo confirmYesNo = const ConfirmYesNo(),
    PublishProcessRunner? publish,
  })  : _getCurrentBranch = getCurrentBranch,
        _parseReleaseBranch = parseReleaseBranch,
        _hasCleanWorkingTree = hasCleanWorkingTree,
        _validatePackagePath = validatePackagePath,
        _getPackageName = getPackageName,
        _getPackageVersion = getPackageVersion,
        _confirmYesNo = confirmYesNo,
        _publish = publish;

  /// Validates and publishes a package from a release branch.
  ///
  /// Params:
  /// - `repoRoot`: absolute path to the repository root.
  /// - `dryRunOnly`: skip the actual publish after a successful dry run.
  ///
  /// Returns: nothing (void); reports progress to stdout.
  ///
  /// Notes: throws [PublishValidationException] on invalid state and
  /// [PublishFailedException] when the dry run or publish fails.
  Future<void> call({
    required String repoRoot,
    bool dryRunOnly = false,
  }) async {
    final publish = _publish ?? _defaultPublish;
    final branch = await _getCurrentBranch(repoRoot);
    if (branch == null) {
      throw const PublishValidationException(
        'Error: Detached HEAD. Checkout a release branch first.',
      );
    }
    final parsed = _parseReleaseBranch(branch);
    if (parsed == null) {
      throw const PublishValidationException(
        'Error: Branch name does not match format release/<package-path>-<version>.',
      );
    }

    final pkgPath = parsed.packagePath;
    _validatePackagePath(repoRoot, pkgPath);

    final pkgName = await _getPackageName(repoRoot, pkgPath);
    final pkgVersion = await _getPackageVersion(repoRoot, pkgPath);

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
    if (!await _hasCleanWorkingTree(repoRoot)) {
      stdout.writeln('  WARNING: You have uncommitted changes.');
      warnings = true;
    }

    if (warnings && !await _confirmYesNo('Continue despite warnings?')) {
      stdout.writeln('Cancelled.');
      return;
    }

    stdout.writeln('\nDRY-RUN PUBLISH');
    final dryExit = await publish(repoRoot, pkgPath, dryRun: true);
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

    final confirmed = await _confirmYesNo(
      'Publish $pkgName@$pkgVersion?',
    );
    if (!confirmed) {
      stdout.writeln('Cancelled.');
      return;
    }

    stdout.writeln('\nPUBLISHING');
    final exitCode = await publish(repoRoot, pkgPath, dryRun: false);
    if (exitCode != 0) {
      throw const PublishFailedException('Error: Publishing failed.');
    }
    stdout.writeln('Successfully published!');
  }

  static Future<int> _defaultPublish(
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

class PublishFailedException implements Exception {
  final String message;

  const PublishFailedException(this.message);
}
