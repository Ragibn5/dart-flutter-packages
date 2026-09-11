import 'package:args/command_runner.dart';
import 'package:dev_tools/src/commands/coverage/run_coverage_command.dart';
import 'package:dev_tools/src/use_cases/coverage/run_flutter_test_with_coverage.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockRunFlutterTestWithCoverage extends Mock
    implements RunFlutterTestWithCoverage {}

void main() {
  late _MockRunFlutterTestWithCoverage runTestWithCoverage;
  late RunCoverageCommand sut;

  setUp(() {
    runTestWithCoverage = _MockRunFlutterTestWithCoverage();
    when(() => runTestWithCoverage(lcovFile: any(named: 'lcovFile')))
        .thenAnswer((_) async {});

    sut = RunCoverageCommand(runTestWithCoverage: runTestWithCoverage);
  });

  test('should expose the run name', () {
    expect(sut.name, RunCoverageCommand.commandName);
  });

  test('should describe running tests with coverage', () {
    expect(sut.description, RunCoverageCommand.commandDescription);
  });

  test('should use the default lcov path when none is provided', () async {
    await _run(<String>[], sut);

    // ignore: avoid_redundant_argument_values
    verify(() => runTestWithCoverage(lcovFile: 'coverage/lcov.info')).called(1);
  });

  test('should forward a supplied lcov path', () async {
    await _run(['--lcov-file=coverage/alt.info'], sut);

    verify(() => runTestWithCoverage(lcovFile: 'coverage/alt.info')).called(1);
  });
}

Future<void> _run(List<String> rest, RunCoverageCommand command) async {
  final runner = CommandRunner<void>('dev_tools', '')..addCommand(command);
  await runner.run(['run', ...rest]);
}
