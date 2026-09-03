import 'package:dev_tools/src/exceptions/command_not_found_exception.dart';
import 'package:dev_tools/src/use_cases/cmd_installation_checker.dart';

class FindFvmAwareFlutterCommand {
  final CmdInstallationChecker _cmdInstallationChecker;

  const FindFvmAwareFlutterCommand({
    CmdInstallationChecker cmdInstallationChecker =
        const CmdInstallationChecker(),
  }) : _cmdInstallationChecker = cmdInstallationChecker;

  Future<String> call() async {
    if (await _cmdInstallationChecker('fvm')) {
      return 'fvm flutter';
    }
    if (await _cmdInstallationChecker('flutter')) {
      return 'flutter';
    }
    throw const CommandNotFoundException(['fvm', 'flutter']);
  }
}
