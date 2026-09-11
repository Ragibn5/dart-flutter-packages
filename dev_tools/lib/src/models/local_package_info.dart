import 'package:dev_tools/src/models/package_identity.dart';
import 'package:meta/meta.dart';

@immutable
class LocalPackageInfo {
  final String repoRootRelativePath;
  final PackageIdentity packageIdentity;

  const LocalPackageInfo({
    required this.repoRootRelativePath,
    required this.packageIdentity,
  });

  @override
  String toString() => 'LocalPackageInfo('
      'repoRootRelativePath: $repoRootRelativePath,'
      'packageIdentity: ${packageIdentity.name}@${packageIdentity.version},'
      ')';

  @override
  bool operator ==(Object other) =>
      other is LocalPackageInfo &&
      other.repoRootRelativePath == repoRootRelativePath &&
      other.packageIdentity == packageIdentity;

  @override
  int get hashCode => Object.hash(repoRootRelativePath, packageIdentity);
}
