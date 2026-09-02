import 'package:dev_tools/src/dev_tools_exception.dart';
import 'package:dev_tools/src/utils/cmd_installation_checker.dart';

class FvmOrDartNotInstalledException extends DevToolsException {
  const FvmOrDartNotInstalledException(super.message);
}

class DartCommandFinder {
  final CmdInstallationChecker _cmdInstallationChecker;

  const DartCommandFinder({
    CmdInstallationChecker cmdInstallationChecker =
        const CmdInstallationChecker(),
  }) : _cmdInstallationChecker = cmdInstallationChecker;

  /// Returns the command string used to run Dart.
  ///
  /// Returns:
  /// - `fvm dart` when fvm was found on PATH.
  /// - `dart` when fvm was not found, but flutter was found on PATH.
  ///
  /// Throws a [FvmOrDartNotInstalledException] if neither `fvm` nor
  /// `flutter` was found on the PATH.
  Future<String> call() async {
    if (await _cmdInstallationChecker.isOnPath('fvm')) return 'fvm dart';
    if (await _cmdInstallationChecker.isOnPath('dart')) return 'dart';
    throw const FvmOrDartNotInstalledException(
      'Error: neither fvm nor dart found on PATH.',
    );
  }
}
