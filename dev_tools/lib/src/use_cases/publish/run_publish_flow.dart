import 'dart:io';

import 'package:dev_tools/src/exceptions/command_execution_exception.dart';
import 'package:dev_tools/src/use_cases/git/has_clean_working_tree.dart';
import 'package:dev_tools/src/use_cases/prompts/confirm_yes_no.dart';
import 'package:dev_tools/src/use_cases/publish/publish_validation_exception.dart';
import 'package:dev_tools/src/use_cases/publish/read_package_identity.dart';
import 'package:dev_tools/src/use_cases/publish/validate_package_path.dart';
import 'package:dev_tools/src/use_cases/publish/verify_release_completeness.dart';

typedef PublishProcessRunner = Future<int> Function(
  String repoRoot,
  String pkgPath, {
  required bool dryRun,
});

class RunPublishFlow {
  final ConfirmYesNo _confirmYesNo;
  final HasCleanWorkingTree _hasCleanWorkingTree;
  final ValidatePackagePath _validatePackagePath;
  final ReadPackageIdentity _readPackageIdentity;
  final VerifyReleaseCompleteness _verifyReleaseCompleteness;
  final PublishProcessRunner? _publish;

  const RunPublishFlow({
    ConfirmYesNo confirmYesNo = const ConfirmYesNo(),
    HasCleanWorkingTree hasCleanWorkingTree = const HasCleanWorkingTree(),
    ValidatePackagePath validatePackagePath = const ValidatePackagePath(),
    ReadPackageIdentity readPackageIdentity = const ReadPackageIdentity(),
    VerifyReleaseCompleteness verifyReleaseCompleteness =
        const VerifyReleaseCompleteness(),
    PublishProcessRunner? publish,
  })  : _confirmYesNo = confirmYesNo,
        _hasCleanWorkingTree = hasCleanWorkingTree,
        _validatePackagePath = validatePackagePath,
        _readPackageIdentity = readPackageIdentity,
        _verifyReleaseCompleteness = verifyReleaseCompleteness,
        _publish = publish;

  /// Validates and publishes a package.
  ///
  /// Params:
  /// - `repoRoot`: absolute path to the repository root.
  /// - `pkgPath`: package directory relative to [repoRoot].
  /// - `dryRunOnly`: skip the actual publish after a successful dry run.
  ///
  /// Returns: nothing (void); reports progress to stdout.
  ///
  /// Notes: throws [PublishValidationException] on invalid state, including
  /// incomplete release references reported by [VerifyReleaseCompleteness];
  /// dedicated reader exceptions surface missing pubspecs or versioned
  /// files; [PublishFailedException] is thrown when the dry run or publish
  /// fails.
  Future<void> call({
    required String repoRoot,
    required String pkgPath,
    bool dryRunOnly = false,
  }) async {
    _validatePackagePath(repoRoot, pkgPath);

    final publish = _publish ?? _defaultPublish;
    final identity = await _readPackageIdentity(repoRoot, pkgPath);

    stdout
      ..writeln('Package: ${identity.name}')
      ..writeln('Version: ${identity.version}');

    await _verifyReleaseCompleteness(repoRoot: repoRoot, pkgPath: pkgPath);

    var warnings = false;
    if (!await _hasCleanWorkingTree(repoRoot)) {
      stdout.writeln('WARNING: You have uncommitted changes.');
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

    final confirmed =
        await _confirmYesNo('Publish ${identity.name}@${identity.version}?');
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

class PublishFailedException extends CommandExecutionException {
  @override
  final String message;

  const PublishFailedException(this.message);
}
