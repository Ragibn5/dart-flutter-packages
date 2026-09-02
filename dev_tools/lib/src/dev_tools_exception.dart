/// Base exception for all failures raised by `dev_tools` utilities.
///
/// [message] is always user-facing: the CLI catches [DevToolsException] and
/// prints it to stderr before exiting with code 1.
class DevToolsException implements Exception {
  const DevToolsException(this.message);

  /// Human-readable error message suitable for terminal output.
  final String message;

  @override
  String toString() => message;
}
