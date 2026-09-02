import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dev_tools/src/dev_tools_exception.dart';

/// Discover and run tests for all packages in a repository.
class TestAllCommand extends Command<void> {
  @override
  String get name => 'test-all';

  @override
  String get description =>
      'Discover and run tests for all packages (runs scripts/run_all_tests.sh).';

  @override
  bool get takesArguments => false;

  @override
  FutureOr<void>? run() async {
    final runner = File('${Directory.current.path}/scripts/run_all_tests.sh');
    if (!runner.existsSync()) {
      throw UsageException(
        'Error: scripts/run_all_tests.sh not found in current directory.',
        '',
      );
    }
    final result = await Process.run('bash', [runner.path]);
    stdout.write(result.stdout);
    stderr.write(result.stderr);
    if (result.exitCode != 0) throw const TestAllException();
  }
}

/// Thrown when the `run_all_tests.sh` script exits with a non-zero code.
class TestAllException extends DevToolsException {
  const TestAllException()
    : super('Error: run_all_tests.sh exited with a non-zero code.');
}
