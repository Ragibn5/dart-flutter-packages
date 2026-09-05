import 'package:dev_tools/src/exceptions/command_not_found_exception.dart';
import 'package:dev_tools/src/use_cases/common/cmd_installation_checker.dart';

class FindFvmAwareDartCommand {
  final CmdInstallationChecker _cmdInstallationChecker;

  const FindFvmAwareDartCommand({
    CmdInstallationChecker cmdInstallationChecker =
        const CmdInstallationChecker(),
  }) : _cmdInstallationChecker = cmdInstallationChecker;

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
