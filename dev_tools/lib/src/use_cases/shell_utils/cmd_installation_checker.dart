import 'dart:io';

class CmdInstallationChecker {
  const CmdInstallationChecker();

  /// Checks whether [executable] is on the system `PATH`.
  ///
  /// Params:
  /// - `executable`: name of the executable to look for.
  ///
  /// Returns: true when found.
  Future<bool> call(String executable) async {
    final which = Platform.isWindows ? 'where' : 'which';
    final result = await Process.run(which, [executable]);
    return result.exitCode == 0;
  }
}
