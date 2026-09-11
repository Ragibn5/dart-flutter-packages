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
