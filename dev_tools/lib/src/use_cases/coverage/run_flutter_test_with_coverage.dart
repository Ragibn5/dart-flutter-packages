import 'package:dev_tools/src/use_cases/dart_flutter/find_fvm_aware_flutter_command.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_project_root.dart';
import 'package:dev_tools/src/utils/interactive_process_runner.dart';

class RunFlutterTestWithCoverage {
  static final RegExp _fvmFlutterPattern = RegExp(r'^(fvm)\s+(flutter)$');

  final FindProjectRoot _findProjectRoot;
  final FindFvmAwareFlutterCommand _findFlutterCommand;

  const RunFlutterTestWithCoverage({
    FindProjectRoot findProjectRoot = const FindProjectRoot(),
    FindFvmAwareFlutterCommand flutterCommandFinder =
        const FindFvmAwareFlutterCommand(),
  })  : _findProjectRoot = findProjectRoot,
        _findFlutterCommand = flutterCommandFinder;

  /// Runs `flutter test --coverage` in the project root.
  ///
  /// Params:
  /// - `lcovFile`: output path of the lcov file, relative to the project
  ///   root (default 'coverage/lcov.info').
  ///
  /// Returns: nothing (void) when the tests pass.
  ///
  /// Notes: throws [FlutterTestWithCoverageException] when the command exits
  /// with a non-zero code.
  Future<void> call({String lcovFile = 'coverage/lcov.info'}) async {
    final projectRoot = await _findProjectRoot();
    final flutterCmd = await _findFlutterCommand();
    final (executable: executable, arguments: leadingArgs) =
        splitCommand(flutterCmd);
    final runner = InteractiveProcessRunner(
      executable: executable,
      arguments: [
        ...leadingArgs,
        'test',
        '--no-test-assets',
        '--coverage',
        '--coverage-path',
        lcovFile,
      ],
      workingDirectory: projectRoot,
    );

    final exitCode = await runner.run();
    if (exitCode != 0) {
      throw FlutterTestWithCoverageException(
        'Error($exitCode): flutter test with coverage failed.',
      );
    }
  }

  /// Splits an fvm-aware flutter command into an executable and any leading
  /// arguments using a pattern, instead of assuming a best-case single-space
  /// split.
  ///
  /// Recognized forms:
  /// - `flutter`: executable `flutter`, no leading arguments.
  /// - `fvm flutter` (with any whitespace between): executable `fvm` and
  ///   leading argument `flutter`.
  /// - anything else: the whole command, trimmed, is used as the executable.
  ///
  /// Returns: a record with the `executable` and its `arguments`.
  static ({String executable, List<String> arguments}) splitCommand(
    String command,
  ) {
    final trimmed = command.trim();
    final match = _fvmFlutterPattern.firstMatch(trimmed);
    if (match != null) {
      return (executable: match.group(1)!, arguments: [match.group(2)!]);
    }
    return (executable: trimmed, arguments: const <String>[]);
  }
}

class FlutterTestWithCoverageException implements Exception {
  final String message;

  const FlutterTestWithCoverageException(this.message);

  @override
  String toString() => message;
}
