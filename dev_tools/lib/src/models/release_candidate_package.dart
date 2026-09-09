import 'package:dev_tools/src/models/local_package_info.dart';
import 'package:dev_tools/src/models/package_identity.dart';
import 'package:dev_tools/src/models/published_package_info.dart';
import 'package:meta/meta.dart';

@immutable
class ReleaseCandidatePackage {
  final LocalPackageInfo localPackageInfo;
  final PublishedPackageInfo publishedPackageInfo;

  const ReleaseCandidatePackage({
    required this.localPackageInfo,
    required this.publishedPackageInfo,
  });

  String get repoRootRelativePath => localPackageInfo.repoRootRelativePath;

  PackageIdentity get packageIdentity => localPackageInfo.packageIdentity;

  @override
  String toString() => 'ReleaseCandidatePackage('
      'localPackageInfo: $localPackageInfo,'
      'publishedPackageInfo: $publishedPackageInfo'
      ')';

  @override
  bool operator ==(Object other) =>
      other is ReleaseCandidatePackage &&
      other.localPackageInfo == localPackageInfo;

  @override
  int get hashCode => localPackageInfo.hashCode;
}
