import 'dart:io';

import 'package:dev_tools/src/exceptions/command_execution_exception.dart';
import 'package:dev_tools/src/models/local_package_info.dart';
import 'package:dev_tools/src/use_cases/publish/read_package_identity.dart';
import 'package:path/path.dart' as p;

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

    final packages = await Future.wait(
      _findPackageDirs(repoRootDir)
          .map((dir) async => _buildLocalPackageInfo(dir, repoRoot)),
    );

    return packages.where(filter).toList();
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

  Future<LocalPackageInfo> _buildLocalPackageInfo(
    Directory dir,
    String repoRoot,
  ) async {
    return LocalPackageInfo(
      repoRootRelativePath: p.relative(dir.path, from: repoRoot),
      packageIdentity: await _readPackageIdentity(dir.absolute.path),
    );
  }
}

class PackageFinderException extends CommandExecutionException {
  @override
  final String message;

  const PackageFinderException(this.message);
}
