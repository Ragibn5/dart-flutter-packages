import 'dart:io';

class CmdInstallationChecker {
  const CmdInstallationChecker();

  Future<bool> isOnPath(String executable) async {
    final which = Platform.isWindows ? 'where' : 'which';
    final result = await Process.run(which, [executable]);
    return result.exitCode == 0;
  }
}
