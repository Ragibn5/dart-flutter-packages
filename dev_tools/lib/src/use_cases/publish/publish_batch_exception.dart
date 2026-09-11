import 'package:dev_tools/src/exceptions/command_execution_exception.dart';

class PublishBatchException extends CommandExecutionException {
  @override
  final String message;

  const PublishBatchException(this.message);
}
