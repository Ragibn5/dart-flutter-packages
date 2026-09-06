import 'package:dev_tools/src/exceptions/command_execution_exception.dart';

class PublishValidationException extends CommandExecutionException {
  @override
  final String message;

  const PublishValidationException(this.message);
}
