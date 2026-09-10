import 'dart:io';

import 'package:dev_tools/src/models/published_package_info.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/read_package_identity.dart';
import 'package:dev_tools/src/use_cases/release/fetch_pub_dev_package_info.dart';
import 'package:dev_tools/src/use_cases/release/package_registry_client.dart';
import 'package:dev_tools/src/use_cases/release/release_validation_exception.dart';
import 'package:dev_tools/src/use_cases/release/verify_versioned_files.dart';
import 'package:pub_semver/pub_semver.dart';

/// Verifies that a package release is complete before publishing.
///
/// Checks the pubspec against its package registry state and the files
/// expected to reference the new version (CHANGELOG.md, README.md, and any
/// additional versioned files).
class VerifyReleaseCompleteness {
  static const _changelogPrefix = r'^#{1,6}\s*\[?';
  static const _changelogSuffix = r'\]?(\s+-.*)?\s*$';
  static const _boundaryOpen = r'(^|[^0-9A-Za-z-])';
  static const _boundaryClose = r'([^0-9A-Za-z-]|$)';
  static const _constraintSeparator = r':\s*\^';

  /// Matches a Markdown heading ending with `<version>`.
  static RegExp _changelogEntryPattern(String name, String version) {
    return RegExp(
      '$_changelogPrefix${RegExp.escape(version)}$_changelogSuffix',
    );
  }

  static String _changelogProblem(String name, String version) {
    return 'CHANGELOG.md has no entry for $version.';
  }

  /// Matches `<package>-<version>` only when surrounded by non-version
  /// characters, so similar strings inside docs or other references (e.g.
  /// `dev_tools: ^1.0.0`) are not counted as a reference.
  static RegExp _gitInstallPattern(String name, String version) {
    final escaped = RegExp.escape('$name-$version');
    return RegExp('$_boundaryOpen$escaped$_boundaryClose');
  }

  static String _gitInstallProblem(String name, String version) {
    return 'README.md does not reference $name-$version (git install).';
  }

  /// Matches the pub registry install form `<package>: ^<version>` only
  /// when surrounded by non-version characters.
  static RegExp _registryInstallPattern(String name, String version) {
    final escapedName = RegExp.escape(name);
    final escapedVersion = RegExp.escape(version);
    return RegExp(
      '$_boundaryOpen$escapedName$_constraintSeparator'
      '$escapedVersion$_boundaryClose',
    );
  }

  static String _registryInstallProblem(String name, String version) {
    return 'README.md does not reference $name: ^$version (registry install).';
  }

  static const _standardChecks = <String, VersionedFileCheck>{
    'changelog': VersionedFileCheck(
      filePath: 'CHANGELOG.md',
      pattern: _changelogEntryPattern,
      problem: _changelogProblem,
      multiLine: true,
    ),
    'readme git install': VersionedFileCheck(
      filePath: 'README.md',
      pattern: _gitInstallPattern,
      problem: _gitInstallProblem,
    ),
    'readme registry install': VersionedFileCheck(
      filePath: 'README.md',
      pattern: _registryInstallPattern,
      problem: _registryInstallProblem,
    ),
  };

  final ReadPackageIdentity _readPackageIdentity;
  final VerifyVersionedFiles _verifyVersionedFiles;
  final PackageRegistryClient _packageRegistryClient;

  const VerifyReleaseCompleteness({
    ReadPackageIdentity readPackageIdentity = const ReadPackageIdentity(),
    VerifyVersionedFiles verifyVersionedFiles = const VerifyVersionedFiles(),
    PackageRegistryClient packageRegistryClient =
        const FetchPubDevPackageInfo(),
  })  : _readPackageIdentity = readPackageIdentity,
        _verifyVersionedFiles = verifyVersionedFiles,
        _packageRegistryClient = packageRegistryClient;

  /// Verifies all release references are consistent.
  ///
  /// Params:
  /// - `packagePath`: absolute path to the package directory.
  /// - `publishedVersions`: known published versions of the package, or null.
  /// - `requiredVersionedFiles`: the versioned file checks to run; defaults
  ///   to the standard CHANGELOG.md and README.md checks. Provide your own
  ///   map to replace them.
  ///
  /// Returns: nothing (void).
  ///
  /// Throws:
  /// - [ReleaseValidationException] listing every missing reference, and
  ///   when the package registry cannot be reached.
  /// - [PackageIdentityException] when the pubspec is missing or lacks a
  ///   `name` or `version` (see [ReadPackageIdentity]).
  /// - [VersionedFileVerificationException] when a checked file does not
  ///   exist (see [VerifyVersionedFiles]).
  ///
  /// Notes: reports progress to stdout.
  Future<void> call(
    String packagePath, {
    PublishedPackageInfo? publishedPackageInfo,
    Map<String, VersionedFileCheck> checks = _standardChecks,
  }) async {
    final identity = await _readPackageIdentity(packagePath);

    final problems = <String>[
      ...await _findPublishedVersionProblems(
        identity.name,
        identity.version,
        publishedPackageInfo,
      ),
      ...await _verifyVersionedFiles(
        packagePath: packagePath,
        name: identity.name,
        version: identity.version,
        requiredVersionedFiles: checks,
      ),
    ];

    if (problems.isNotEmpty) {
      throw ReleaseValidationException(
        'Error: Release is incomplete for '
        '${identity.name}@${identity.version}:\n'
        '${problems.map((e) => '- $e').join('\n')}',
      );
    }

    stdout.writeln(
      'All release references are consistent for '
      '${identity.name}@${identity.version}.',
    );
  }

  /// Collects registry-related problems: the version being released is
  /// either already published or lower than the latest published version.
  Future<List<String>> _findPublishedVersionProblems(
    String name,
    String version,
    PublishedPackageInfo? publishedVersions,
  ) async {
    final PublishedPackageInfo info;
    if (publishedVersions != null) {
      info = publishedVersions;
    } else {
      try {
        info = await _packageRegistryClient(name);
      } on PackageRegistryLookupException catch (e) {
        throw ReleaseValidationException(
          'Error: Could not reach the package registry to verify $name: '
          '${e.message}',
        );
      }
    }

    if (info.versions.contains(version)) {
      return ['$name@$version is already published.'];
    }

    final latest = info.latestVersion;
    final newVersion = _parseVersionOrNull(version);
    final latestVersion = latest == null ? null : _parseVersionOrNull(latest);
    if (newVersion != null &&
        latestVersion != null &&
        newVersion < latestVersion) {
      final message = 'A newer version ($latest) is already published; '
          '$version must be greater.';
      return [message];
    }
    return const [];
  }

  static Version? _parseVersionOrNull(String version) {
    try {
      return Version.parse(version);
    } on FormatException {
      return null;
    }
  }
}
