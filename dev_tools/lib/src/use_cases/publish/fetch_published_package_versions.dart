import 'dart:convert';
import 'dart:io';

import 'package:dev_tools/src/exceptions/command_execution_exception.dart';

/// Information about versions of a package fetched from pub.dev.
class PubDevPackageInfo {
  const PubDevPackageInfo({this.latestVersion, this.versions = const []});

  /// The latest published version, or null when nothing is published.
  final String? latestVersion;

  /// All published versions, empty when nothing is published.
  final List<String> versions;
}

/// Represents an exception when the pub.dev API cannot be queried.
class PubDevLookupException extends CommandExecutionException {
  @override
  final String message;

  const PubDevLookupException(this.message);
}

class FetchPublishedPackageVersions {
  const FetchPublishedPackageVersions();

  /// Retrieves the latest and all published versions for [packageName].
  ///
  /// Returns: a [PubDevPackageInfo]; empty when the package has never been
  /// published.
  ///
  /// Notes: throws [PubDevLookupException] when the pub.dev API cannot be
  /// queried or returns an unexpected status.
  Future<PubDevPackageInfo> call(String packageName) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(
        Uri.parse('https://pub.dev/api/packages/$packageName'),
      );
      final response = await request.close();
      if (response.statusCode == HttpStatus.notFound) {
        return const PubDevPackageInfo();
      }
      if (response.statusCode != HttpStatus.ok) {
        throw PubDevLookupException(
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

      return PubDevPackageInfo(latestVersion: latest, versions: versions);
    } on PubDevLookupException {
      rethrow;
    } catch (e) {
      throw PubDevLookupException(
        'Could not reach pub.dev to verify $packageName: $e',
      );
    } finally {
      client.close(force: true);
    }
  }
}
