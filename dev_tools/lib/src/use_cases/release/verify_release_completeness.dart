import 'package:dev_tools/src/models/published_package_info.dart';
import 'package:dev_tools/src/models/release_issue.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/read_package_identity.dart';
import 'package:dev_tools/src/use_cases/release/verify_versioned_files.dart';
import 'package:pub_semver/pub_semver.dart';

/// Verifies that a package release is complete before publishing.
///
/// Checks a known package registry state and the files expected to
/// reference the new version (CHANGELOG.md, README.md, and any additional
/// versioned files), returning a [ReleaseIssue] for each problem found
/// rather than throwing.
class VerifyReleaseCompleteness {
  final ReadPackageIdentity _readPackageIdentity;
  final VerifyVersionedFiles _verifyVersionedFiles;

  const VerifyReleaseCompleteness({
    ReadPackageIdentity readPackageIdentity = const ReadPackageIdentity(),
    VerifyVersionedFiles verifyVersionedFiles = const VerifyVersionedFiles(),
  })  : _readPackageIdentity = readPackageIdentity,
        _verifyVersionedFiles = verifyVersionedFiles;

  /// Verifies all release references are consistent.
  ///
  /// Params:
  /// - `packagePath`: absolute path to the package directory.
  /// - `publishedPackageInfo`: the package's known published versions —
  ///   the caller's responsibility to fetch (e.g. via a
  ///   `PackageRegistryClient`).
  /// - `checks`: the versioned file checks to run (e.g.
  ///   `buildStandardReleaseChecks`) — the caller's responsibility to
  ///   build, so it can be constructed from the same `GetTagFormat` the
  ///   caller uses elsewhere.
  ///
  /// Returns: a [ReleaseIssue] for every problem found (an already-published
  /// or out-of-order version, and any missing or out-of-date versioned-file
  /// references); empty when the release is complete.
  ///
  /// Throws:
  /// - [PackageIdentityException] when the pubspec is missing or lacks a
  ///   `name` or `version` (see [ReadPackageIdentity]).
  Future<List<ReleaseIssue>> call(
    String packagePath, {
    required PublishedPackageInfo publishedPackageInfo,
    required Map<String, VersionedFileCheck> checks,
  }) async {
    final identity = await _readPackageIdentity(packagePath);

    final problems = <String>[
      ..._findPublishedVersionProblems(
        identity.name,
        identity.version,
        publishedPackageInfo,
      ),
      ...await _verifyVersionedFiles(
        packagePath: packagePath,
        name: identity.name,
        version: identity.version,
        checks: checks,
      ),
    ];

    return problems.map(ReleaseIssue.new).toList();
  }

  /// Collects registry-related problems: the version being released is
  /// either already published or lower than the latest published version.
  List<String> _findPublishedVersionProblems(
    String name,
    String version,
    PublishedPackageInfo info,
  ) {
    if (info.versions.contains(version)) {
      return ['$name@$version is already published.'];
    }

    final latest = info.latestVersion;
    final newVersion = _parseVersionOrNull(version);
    final latestVersion = latest == null ? null : _parseVersionOrNull(latest);
    if (newVersion != null &&
        latestVersion != null &&
        newVersion < latestVersion) {
      return [
        // ignore: lines_longer_than_80_chars
        'A newer version ($latest) is already published; $version must be greater.'
      ];
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
