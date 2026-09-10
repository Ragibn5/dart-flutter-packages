import 'dart:convert';
import 'dart:io';

import 'package:dev_tools/src/models/published_package_info.dart';
import 'package:dev_tools/src/use_cases/release/package_registry_client.dart';

/// Looks up a package's published state on pub.dev.
class FetchPubDevPackageInfo implements PackageRegistryClient {
  const FetchPubDevPackageInfo();

  @override
  Future<PublishedPackageInfo> call(String packageName) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(
        Uri.parse('https://pub.dev/api/packages/$packageName'),
      );
      final response = await request.close();
      if (response.statusCode == HttpStatus.notFound) {
        return const PublishedPackageInfo();
      }
      if (response.statusCode != HttpStatus.ok) {
        throw PackageRegistryLookupException(
          'pub.dev returned status ${response.statusCode} for $packageName.',
        );
      }

      final body = await response.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;

      String? latest;
      final latestEntry = json['latest'];
      if (latestEntry is Map<String, dynamic>) {
        latest = latestEntry['version'] as String?;
      }

      final versions = <String>[];
      final versionEntries = json['versions'];
      if (versionEntries is List) {
        for (final entry in versionEntries) {
          if (entry is Map && entry['version'] is String) {
            versions.add(entry['version'] as String);
          }
        }
      }

      return PublishedPackageInfo(latestVersion: latest, versions: versions);
    } on PackageRegistryLookupException {
      rethrow;
    } catch (e) {
      throw PackageRegistryLookupException(
        'Could not reach pub.dev to verify $packageName: $e',
      );
    } finally {
      client.close(force: true);
    }
  }
}
