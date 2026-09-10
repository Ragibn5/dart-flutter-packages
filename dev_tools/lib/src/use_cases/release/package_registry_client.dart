import 'package:dev_tools/src/exceptions/command_execution_exception.dart';
import 'package:dev_tools/src/models/published_package_info.dart';

/// A client that looks up a package's published state on a package
/// registry (e.g. pub.dev, or a self-hosted alternative).
abstract class PackageRegistryClient {
  /// Retrieves the latest and all published versions for [packageName].
  ///
  /// Returns: a [PublishedPackageInfo]; empty when the package has never
  /// been published.
  ///
  /// Throws:
  /// - [PackageRegistryLookupException] when the registry cannot be
  ///   queried or returns an unexpected status.
  Future<PublishedPackageInfo> call(String packageName);
}

/// Represents an exception when a package registry cannot be queried.
class PackageRegistryLookupException extends CommandExecutionException {
  @override
  final String message;

  const PackageRegistryLookupException(this.message);
}
