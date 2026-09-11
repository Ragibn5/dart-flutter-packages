import 'package:dev_tools/src/models/release_candidate_package.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_packages.dart';
import 'package:dev_tools/src/use_cases/release/fetch_pub_dev_package_info.dart';
import 'package:dev_tools/src/use_cases/release/package_registry_client.dart';
import 'package:path/path.dart' as p;

/// Finds packages pending release among a set of changed files.
///
/// A package is a release candidate when it was touched (per `changedFiles`,
/// e.g. from `DetectChangesInFolder`), has a pubspec.yaml, does not opt out
/// of publishing (`publish_to: none`, the convention for apps and other
/// non-published packages), and its current version is not yet published
/// on the package registry (covering both version bumps and brand-new
/// packages).
class FindReleaseCandidatePackages {
  final FindPackages _findPackages;
  final PackageRegistryClient _packageRegistryClient;

  const FindReleaseCandidatePackages({
    FindPackages findPackages = const FindPackages(),
    PackageRegistryClient packageRegistryClient =
        const FetchPubDevPackageInfo(),
  })  : _findPackages = findPackages,
        _packageRegistryClient = packageRegistryClient;

  /// Finds release-candidate packages.
  ///
  /// Params:
  /// - `repoRoot`: absolute path to the repository root; its working tree
  ///   must reflect the state `changedFiles` was computed against.
  /// - `changedFiles`: repository-root-relative paths of touched files,
  ///   e.g. from `DetectChangesInFolder`.
  ///
  /// Returns: candidate packages, in no particular order.
  ///
  /// Throws:
  /// - [PackageFinderException] when `repoRoot` does not exist.
  /// - [PackageRegistryLookupException] when the package registry cannot
  ///   be reached.
  Future<List<ReleaseCandidatePackage>> call({
    required String repoRoot,
    required List<String> changedFiles,
  }) async {
    final touchedPublishablePackages = await _findPackages(
      repoRoot: repoRoot,
      filter: (local) =>
          local.packageIdentity.isPublishable &&
          _isTouched(local.repoRootRelativePath, changedFiles),
    );

    final candidates = <ReleaseCandidatePackage>[];
    for (final package in touchedPublishablePackages) {
      final info = await _packageRegistryClient(
        package.packageIdentity.name,
      );
      if (!info.versions.contains(package.packageIdentity.version)) {
        candidates.add(
          ReleaseCandidatePackage(
            localPackageInfo: package,
            publishedPackageInfo: info,
          ),
        );
      }
    }
    return candidates;
  }

  /// Whether any of [changedFiles] is the package directory itself or lies
  /// underneath it.
  bool _isTouched(String packageRelPath, List<String> changedFiles) {
    return changedFiles.any(
      (file) =>
          p.equals(file, packageRelPath) || p.isWithin(packageRelPath, file),
    );
  }
}
