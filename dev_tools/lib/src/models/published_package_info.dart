import 'package:meta/meta.dart';

@immutable
class PublishedPackageInfo {
  /// The latest published version, or null when nothing is published.
  final String? latestVersion;

  /// All published versions, empty when nothing is published.
  final List<String> versions;

  const PublishedPackageInfo({this.latestVersion, this.versions = const []});

  @override
  String toString() => 'PublishedPackageInfo('
      'latestVersion: $latestVersion,'
      'versions: $versions,'
      ')';

  @override
  bool operator ==(Object other) =>
      other is PublishedPackageInfo &&
      other.latestVersion == latestVersion &&
      other.versions == versions;

  @override
  int get hashCode => Object.hash(latestVersion, versions);
}
