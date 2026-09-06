/// The identity of dart/flutter package.
class PackageIdentity {
  final String name;
  final String version;
  final bool isFlutterPackage;

  const PackageIdentity({
    required this.name,
    required this.version,
    this.isFlutterPackage = false,
  });
}