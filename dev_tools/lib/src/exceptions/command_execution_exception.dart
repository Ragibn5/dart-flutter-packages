abstract class CommandExecutionException implements Exception {
  String get message;

  const CommandExecutionException();

  @override
  String toString() => message;
}
