import 'package:dev_tools/src/dev_tools_exception.dart';
import 'package:dev_tools/src/utils/cmd_installation_checker.dart';

class FvmOrFlutterNotInstalledException extends DevToolsException {
  const FvmOrFlutterNotInstalledException(super.message);
}

class FlutterCommandFinder {
  final CmdInstallationChecker _cmdInstallationChecker;

  const FlutterCommandFinder({
    CmdInstallationChecker cmdInstallationChecker =
        const CmdInstallationChecker(),
  }) : _cmdInstallationChecker = cmdInstallationChecker;

  /// Returns the command string used to run Flutter.
  ///
  /// Returns:
  /// - `fvm flutter` when fvm was found on PATH.
  /// - `flutter` when fvm was not found, but flutter was found on PATH.
  ///
  /// Throws a [FvmOrFlutterNotInstalledException] if neither `fvm` nor
  /// `flutter` was found on the PATH.
  Future<String> call() async {
    if (await _cmdInstallationChecker.isOnPath('fvm')) return 'fvm flutter';
    if (await _cmdInstallationChecker.isOnPath('flutter')) return 'flutter';
    throw const FvmOrFlutterNotInstalledException(
      'Error: neither fvm nor flutter found on PATH.',
    );
  }
}
