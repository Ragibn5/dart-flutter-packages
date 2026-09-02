import 'dart:io';

import 'package:dev_tools/src/use_cases/fvm_aware_flutter_command_finder.dart';
import 'package:dev_tools/src/use_cases/find_project_root.dart';

class RunFlutterTestWithCoverage {
  final FindProjectRoot _findProjectRoot;
  final FvmAwareFlutterCommandFinder _findFlutterCommand;

  const RunFlutterTestWithCoverage({
    FindProjectRoot findProjectRoot = const FindProjectRoot(),
    FvmAwareFlutterCommandFinder flutterCommandFinder =
        const FvmAwareFlutterCommandFinder(),
  })  : _findProjectRoot = findProjectRoot,
        _findFlutterCommand = flutterCommandFinder;

  Future<void> call() async {
    final projectRoot = await _findProjectRoot();
    final flutterCmd = await _findFlutterCommand();
    final parts = flutterCmd.split(' ');
    final result = await Process.run(
      parts.first,
      [
        ...parts,
        'test',
        '--no-test-assets',
        '--coverage',
        '--coverage-path',
        'coverage/lcov.info',
      ],
      workingDirectory: projectRoot,
    );
    if (result.exitCode != 0) {
      throw FlutterTestWithCoverageException(
        'Error: flutter test with coverage failed.\n'
        '${result.stdout}${result.stderr}',
      );
    }
  }
}

class FlutterTestWithCoverageException implements Exception {
  final String message;

  const FlutterTestWithCoverageException(this.message);

  @override
  String toString() => message;
}
