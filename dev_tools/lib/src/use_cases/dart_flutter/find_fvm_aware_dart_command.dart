import 'package:dev_tools/src/exceptions/command_not_found_exception.dart';
import 'package:dev_tools/src/use_cases/shell_utils/cmd_installation_checker.dart';

class FindFvmAwareDartCommand {
  final CmdInstallationChecker _cmdInstallationChecker;

  const FindFvmAwareDartCommand({
    CmdInstallationChecker cmdInstallationChecker =
        const CmdInstallationChecker(),
  }) : _cmdInstallationChecker = cmdInstallationChecker;

  /// Resolves the Dart command to run, preferring an fvm-scoped Dart.
  ///
  /// Returns: `'fvm dart'` when fvm is installed, else `'dart'` when the
  /// system-wide Dart is installed.
  ///
  /// Throws:
  /// - [CommandNotFoundException] when neither is installed.
  Future<String> call() async {
    if (await _cmdInstallationChecker('fvm')) {
      return 'fvm dart';
    }
    if (await _cmdInstallationChecker('dart')) {
      return 'dart';
    }
    throw const CommandNotFoundException(['fvm', 'dart']);
  }
}
