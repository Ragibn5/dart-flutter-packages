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
import 'package:dev_tools/src/utils/buffer_sink.dart';
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
  /// - `interactive`: when false, skip both confirmation prompts (warnings
  ///   are still logged, just not gated on); for unattended/CI callers that
  ///   have already decided this candidate should be published.
  /// - `verbose`: when false, suppress all progress output (package/version,
  ///   warnings, dry-run/publish progress) — including `dart pub publish`'s
  ///   own console output, captured and only printed if it actually fails;
  ///   for batch callers that only want to know about failures, reporting
  ///   their own progress (or none) at a coarser level.
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
  /// warned that the system-wide Dart/Flutter will be used. When
  /// `interactive` is true (the default), warnings (system-wide toolchain,
  /// uncommitted changes) are confirmed with a single `Continue despite
  /// warnings?` prompt, and the actual publish requires a final
  /// confirmation. When `verbose`, reports one line per step (package,
  /// warnings if any, dry-run, publish) — no empty sections, no shouting.
  Future<void> call({
    required String repoRoot,
    required String pkgPath,
    bool dryRunOnly = true,
    bool interactive = true,
    bool verbose = true,
  }) async {
    void log(String message) {
      if (verbose) stdout.writeln(message);
    }

    final packagePath = p.join(repoRoot, pkgPath);
    _validatePackagePath(packagePath);

    final warnings = <String>[];
    final publish = _publish ?? (verbose ? _defaultPublish : _silentPublish);
    final identity = await _readPackageIdentity(packagePath);
    final tooling = await _buildPublishCommand(identity);
    final label = '${identity.name}@${identity.version}';

    log('Publishing $label');

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
    for (final w in warnings) {
      log('  Warning: $w');
    }

    if (interactive &&
        warnings.isNotEmpty &&
        !await _confirmYesNo('Continue despite warnings?')) {
      log('  Cancelled.');
      return;
    }

    final dryExit =
        await publish(repoRoot, pkgPath, tooling: tooling, dryRun: true);
    if (dryExit != 0) {
      throw const PublishFailedException(
        'Error: Dry-run failed. Fix issues before publishing.',
      );
    }
    log('  Dry-run publish passed.');

    if (dryRunOnly) {
      log('  Skipping actual publish (dry-run only).');
      return;
    }

    if (interactive) {
      final confirmed = await _confirmYesNo('Publish $label?');
      if (!confirmed) {
        log('  Cancelled.');
        return;
      }
    }

    final exitCode =
        await publish(repoRoot, pkgPath, tooling: tooling, dryRun: false);
    if (exitCode != 0) {
      throw const PublishFailedException('Error: Publishing failed.');
    }
    log('  Published.');
  }

  static Future<int> _defaultPublish(
    String repoRoot,
    String pkgPath, {
    required PublishTooling tooling,
    required bool dryRun,
  }) {
    return _runPubPublish(repoRoot, pkgPath, tooling: tooling, dryRun: dryRun);
  }

  /// Same as [_defaultPublish], but captures `dart pub publish`'s own
  /// console output instead of letting it print — surfaced only if the
  /// process actually fails, so a quiet batch run stays quiet on success.
  static Future<int> _silentPublish(
    String repoRoot,
    String pkgPath, {
    required PublishTooling tooling,
    required bool dryRun,
  }) async {
    final out = BufferSink();
    final err = BufferSink();
    final exitCode = await _runPubPublish(
      repoRoot,
      pkgPath,
      tooling: tooling,
      dryRun: dryRun,
      stdOut: out,
      stdErr: err,
    );
    if (exitCode != 0) {
      stdout.write(out.contents);
      stderr.write(err.contents);
    }
    return exitCode;
  }

  static Future<int> _runPubPublish(
    String repoRoot,
    String pkgPath, {
    required PublishTooling tooling,
    required bool dryRun,
    IOSink? stdOut,
    IOSink? stdErr,
  }) {
    final args = [
      ...tooling.prefix,
      'pub',
      'publish',
      if (dryRun) '--dry-run',
      // Our own flow already gates the decision to publish (interactively
      // or not), so skip pub's own "are you sure?" prompt — it would hang
      // forever in a non-interactive (CI) run.
      if (!dryRun) '--force',
    ];
    final runner = InteractiveProcessRunner(
      executable: args.first,
      arguments: args.sublist(1),
      workingDirectory: '$repoRoot/$pkgPath',
      stdOut: stdOut,
      stdErr: stdErr,
    );
    return runner.run();
  }
}

class PublishFailedException extends CommandExecutionException {
  @override
  final String message;

  const PublishFailedException(this.message);
}
