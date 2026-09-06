import 'package:dev_tools/src/exceptions/command_execution_exception.dart';
import 'package:meta/meta.dart';

class CommandNotFoundException extends CommandExecutionException {
  @visibleForTesting
  final List<String> programs;

  const CommandNotFoundException(this.programs);

  @override
  String get message =>
      "Command(s) not found: '${programs.map((e) => "'$e'").join(', ')}'"
      '                      Make sure they are installed.';
}
