import 'dart:io';

import 'package:dev_tools/src/exceptions/command_execution_exception.dart';
import 'package:dev_tools/src/exceptions/command_not_found_exception.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/read_package_identity.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/validate_package_path.dart';
import 'package:dev_tools/src/use_cases/git/get_tag_format.dart';
import 'package:dev_tools/src/use_cases/git/has_clean_working_tree.dart';
import 'package:dev_tools/src/use_cases/prompts/confirm_yes_no.dart';
import 'package:dev_tools/src/use_cases/publish/build_publish_command.dart';
import 'package:dev_tools/src/use_cases/publish/publish_validation_exception.dart';
import 'package:dev_tools/src/use_cases/release/fetch_pub_dev_package_info.dart';
import 'package:dev_tools/src/use_cases/release/package_registry_client.dart';
import 'package:dev_tools/src/use_cases/release/release_validation_exception.dart';
import 'package:dev_tools/src/use_cases/release/standard_release_checks_builder.dart';
import 'package:dev_tools/src/use_cases/release/verify_release_completeness.dart';
import 'package:dev_tools/src/utils/interactive_process_runner.dart';
import 'package:path/path.dart' as p;

typedef PublishProcessRunner = Future<int> Function(
  String repoRoot,
  String pkgPath, {
  required PublishTooling tooling,
  required bool dryRun,
});

class RunPublishFlow {
  final ConfirmYesNo _confirmYesNo;
  final HasCleanWorkingTree _hasCleanWorkingTree;
  final ValidatePackagePath _validatePackagePath;
  final ReadPackageIdentity _readPackageIdentity;
  final BuildPublishCommand _buildPublishCommand;
  final VerifyReleaseCompleteness _verifyReleaseCompleteness;
  final PackageRegistryClient _packageRegistryClient;
  final GetTagFormat _gitTagFormat;
  final BuildStandardReleaseChecksBuilder _buildStandardReleaseChecks;
  final PublishProcessRunner? _publish;

  const RunPublishFlow({
    ConfirmYesNo confirmYesNo = const ConfirmYesNo(),
    HasCleanWorkingTree hasCleanWorkingTree = const HasCleanWorkingTree(),
    ValidatePackagePath validatePackagePath = const ValidatePackagePath(),
    ReadPackageIdentity readPackageIdentity = const ReadPackageIdentity(),
    BuildPublishCommand buildPublishCommand = const BuildPublishCommand(),
    VerifyReleaseCompleteness verifyReleaseCompleteness =
        const VerifyReleaseCompleteness(),
    PackageRegistryClient packageRegistryClient =
        const FetchPubDevPackageInfo(),
    GetTagFormat gitTagFormat = const GetTagFormat(ResolveGitTagFormat()),
    BuildStandardReleaseChecksBuilder buildStandardReleaseChecks =
        const BuildStandardReleaseChecksBuilder(),
    PublishProcessRunner? publish,
  })  : _confirmYesNo = confirmYesNo,
        _hasCleanWorkingTree = hasCleanWorkingTree,
        _validatePackagePath = validatePackagePath,
        _readPackageIdentity = readPackageIdentity,
        _buildPublishCommand = buildPublishCommand,
        _verifyReleaseCompleteness = verifyReleaseCompleteness,
        _packageRegistryClient = packageRegistryClient,
        _gitTagFormat = gitTagFormat,
        _buildStandardReleaseChecks = buildStandardReleaseChecks,
        _publish = publish;

  /// Validates and publishes a package.
  ///
  /// Params:
  /// - `repoRoot`: absolute path to the repository root.
  /// - `pkgPath`: package directory relative to [repoRoot].
  /// - `dryRunOnly`: skip the actual publish after a successful dry run.
  ///
  /// Returns: nothing (void).
  ///
  /// Throws:
  /// - [PublishValidationException] on an invalid package path.
  /// - [PackageIdentityException] when the pubspec is missing or lacks a
  ///   `name` or `version` (see [ReadPackageIdentity]).
  /// - [CommandNotFoundException] when neither fvm nor a system-wide
  ///   Dart/Flutter is installed (see [BuildPublishCommand]).
  /// - [PackageRegistryLookupException] when the package registry cannot
  ///   be reached.
  /// - [ReleaseValidationException] on incomplete release references (see
  ///   [VerifyReleaseCompleteness]).
  /// - [PublishFailedException] when the dry run or publish fails.
  ///
  /// Notes: the dry run and publish run from the package root using the
  /// tooling in [PublishTooling]; without a scoped fvm version the user is
  /// warned that the system-wide Dart/Flutter will be used. Warnings
  /// (system-wide toolchain, uncommitted changes) are confirmed with a
  /// single `Continue despite warnings?` prompt. Reports progress to
  /// stdout.
  Future<void> call({
    required String repoRoot,
    required String pkgPath,
    bool dryRunOnly = false,
  }) async {
    final packagePath = p.join(repoRoot, pkgPath);
    _validatePackagePath(packagePath);

    final warnings = <String>[];
    final publish = _publish ?? _defaultPublish;
    final identity = await _readPackageIdentity(packagePath);
    final tooling = await _buildPublishCommand(identity);

    stdout
      ..writeln('Package: ${identity.name}')
      ..writeln('Version: ${identity.version}')
      ..writeln();

    final publishedPackageInfo = await _packageRegistryClient(identity.name);
    final releaseIssues = await _verifyReleaseCompleteness(
      packagePath,
      publishedPackageInfo: publishedPackageInfo,
      checks: _buildStandardReleaseChecks.build(_gitTagFormat),
    );
    if (releaseIssues.isNotEmpty) {
      throw ReleaseValidationException(
        releaseIssues.map((i) => i.issueMessage).join('\n'),
      );
    }

    if (!tooling.usesFvm) {
      warnings.add(
        'Project not scoped with fvm, will use system-wide Dart/Flutter.',
      );
    }
    if (!await _hasCleanWorkingTree(repoRoot)) {
      warnings.add('You have uncommitted changes.');
    }
    stdout.writeln('\nWarnings:');
    for (final e in warnings) {
      stdout.writeln('  - $e');
    }
    stdout.writeln();

    if (warnings.isNotEmpty &&
        !await _confirmYesNo('Continue despite warnings?')) {
      stdout.writeln('Cancelled.');
      return;
    }

    stdout.writeln('\nDRY-RUN PUBLISH');
    final dryExit =
        await publish(repoRoot, pkgPath, tooling: tooling, dryRun: true);
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
    final exitCode =
        await publish(repoRoot, pkgPath, tooling: tooling, dryRun: false);
    if (exitCode != 0) {
      throw const PublishFailedException('Error: Publishing failed.');
    }
    stdout.writeln('Successfully published!');
  }

  static Future<int> _defaultPublish(
    String repoRoot,
    String pkgPath, {
    required PublishTooling tooling,
    required bool dryRun,
  }) async {
    final args = [
      ...tooling.prefix,
      'pub',
      'publish',
      if (dryRun) '--dry-run',
    ];
    final runner = InteractiveProcessRunner(
      executable: args.first,
      arguments: args.sublist(1),
      workingDirectory: '$repoRoot/$pkgPath',
    );
    return runner.run();
  }
}

class PublishFailedException extends CommandExecutionException {
  @override
  final String message;

  const PublishFailedException(this.message);
}
