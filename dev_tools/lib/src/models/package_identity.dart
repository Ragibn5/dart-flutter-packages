import 'package:meta/meta.dart';

/// The identity of dart/flutter package.
@immutable
class PackageIdentity {
  final String name;
  final String version;
  final bool isPublishable;
  final bool isFlutterPackage;

  const PackageIdentity({
    required this.name,
    required this.version,
    this.isPublishable = true,
    this.isFlutterPackage = false,
  });

  /// The git-install reference for a package release (e.g. `foo-1.0.0`):
  /// the name of the git tag a release creates, and the exact form its
  /// README's git-install snippet is expected to reference.
  static String gitTag(String name, String version) => '$name-$version';

  /// [gitTag] for this identity's own [name] and [version].
  String get releaseTag => gitTag(name, version);

  @override
  bool operator ==(Object other) =>
      other is PackageIdentity &&
      other.name == name &&
      other.version == version &&
      other.isPublishable == isPublishable &&
      other.isFlutterPackage == isFlutterPackage;

  @override
  int get hashCode =>
      Object.hash(name, version, isPublishable, isFlutterPackage);
}
