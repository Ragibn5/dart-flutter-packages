import 'dart:io';

import 'package:dev_tools/src/exceptions/command_execution_exception.dart';
import 'package:dev_tools/src/models/local_package_info.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/read_package_identity.dart';
import 'package:path/path.dart' as p;

/// Finds every package directory (one containing a `pubspec.yaml`) under a
/// repository root and returns those matching `filter`.
///
/// A directory whose pubspec can't be read as a package identity (missing,
/// or lacking `name`/`version` — common for internal, unpublished packages)
/// is skipped rather than failing the whole scan.
class FindPackages {
  /// Directories that never contain source packages worth scanning, and can
  /// be large enough to dominate the walk if not pruned (build output, caches,
  /// VCS metadata, IDE state etc.).
  static const _ignoredDirNames = {
    '.dart_tool',
    '.git',
    '.idea',
    '.pub-cache',
    '.symlinks',
    'build',
    'node_modules',
    'Pods',
  };

  final ReadPackageIdentity _readPackageIdentity;

  const FindPackages({
    ReadPackageIdentity readPackageIdentity = const ReadPackageIdentity(),
  }) : _readPackageIdentity = readPackageIdentity;

  Future<List<LocalPackageInfo>> call({
    required String repoRoot,
    required bool Function(LocalPackageInfo localPackageInfo) filter,
  }) async {
    final repoRootDir = Directory(repoRoot);
    if (!repoRootDir.existsSync()) {
      throw PackageFinderException('Repository root not found: $repoRoot');
    }

    final results = await Future.wait(
      _findPackageDirs(repoRootDir).map((dir) => _tryBuildLocalPackageInfo(
            dir,
            p.relative(dir.path, from: repoRoot),
          )),
    );

    // Reported after every directory has resolved (rather than as each
    // completes) so skips print in a stable, traversal order regardless of
    // how the underlying async reads happen to interleave.
    for (final result in results) {
      if (result.skipReason != null) {
        stdout.writeln('Skipping ${result.repoRootRelativePath}: '
            '${result.skipReason}');
      }
    }

    return results
        .map((result) => result.package)
        .whereType<LocalPackageInfo>()
        .where(filter)
        .toList();
  }

  Iterable<Directory> _findPackageDirs(Directory dir) sync* {
    if (File(p.join(dir.path, 'pubspec.yaml')).existsSync()) {
      yield dir;
    }

    for (final entry in dir.listSync(followLinks: false)) {
      if (entry is Directory &&
          !_ignoredDirNames.contains(p.basename(entry.path))) {
        yield* _findPackageDirs(entry);
      }
    }
  }

  /// Builds a [LocalPackageInfo] for [dir], capturing why it couldn't be
  /// built (e.g. an internal, unpublished package with no `version`)
  /// instead of letting the failure propagate.
  Future<
      ({
        LocalPackageInfo? package,
        String repoRootRelativePath,
        String? skipReason,
      })> _tryBuildLocalPackageInfo(
    Directory dir,
    String repoRootRelativePath,
  ) async {
    try {
      final package = LocalPackageInfo(
        repoRootRelativePath: repoRootRelativePath,
        packageIdentity: await _readPackageIdentity(dir.absolute.path),
      );
      return (
        package: package,
        repoRootRelativePath: repoRootRelativePath,
        skipReason: null,
      );
    } on PackageIdentityException catch (e) {
      final reason = e.message.replaceFirst(RegExp('^Error: ?'), '');
      return (
        package: null,
        repoRootRelativePath: repoRootRelativePath,
        skipReason: reason,
      );
    }
  }
}

class PackageFinderException extends CommandExecutionException {
  @override
  final String message;

  const PackageFinderException(this.message);
}
