import 'package:dev_tools/src/use_cases/find_fvm_aware_flutter_command.dart';
import 'package:dev_tools/src/use_cases/find_project_root.dart';
import 'package:dev_tools/src/utils/interactive_process_runner.dart';

class RunFlutterTestWithCoverage {
  final FindProjectRoot _findProjectRoot;
  final FindFvmAwareFlutterCommand _findFlutterCommand;

  const RunFlutterTestWithCoverage({
    FindProjectRoot findProjectRoot = const FindProjectRoot(),
    FindFvmAwareFlutterCommand flutterCommandFinder =
        const FindFvmAwareFlutterCommand(),
  })  : _findProjectRoot = findProjectRoot,
        _findFlutterCommand = flutterCommandFinder;

  Future<void> call() async {
    final projectRoot = await _findProjectRoot();
    final flutterCmd = await _findFlutterCommand();
    final parts = flutterCmd.split(' ');
    final runner = InteractiveProcessRunner(
      executable: parts.first,
      arguments: [
        ...parts.sublist(1),
        'test',
        '--no-test-assets',
        '--coverage',
        '--coverage-path',
        'coverage/lcov.info',
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
}

class FlutterTestWithCoverageException implements Exception {
  final String message;

  const FlutterTestWithCoverageException(this.message);

  @override
  String toString() => message;
}
