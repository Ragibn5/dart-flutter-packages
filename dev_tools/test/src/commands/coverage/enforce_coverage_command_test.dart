import 'package:args/command_runner.dart';
import 'package:dev_tools/src/commands/coverage/enforce_coverage_command.dart';
import 'package:dev_tools/src/use_cases/coverage/check_coverage_with_threshold.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockEnforceCoverageThreshold extends Mock
    implements EnforceCoverageThreshold {}

void main() {
  late _MockEnforceCoverageThreshold checkCoverage;
  late EnforceCoverageCommand sut;

  setUp(() {
    checkCoverage = _MockEnforceCoverageThreshold();
    when(() => checkCoverage(
          lcovFile: any(named: 'lcovFile'),
          threshold: any(named: 'threshold'),
        )).thenAnswer((_) async {});
    sut = EnforceCoverageCommand(checkCoverage: checkCoverage);
  });

  test('should expose the enforce name', () {
    expect(sut.name, EnforceCoverageCommand.commandName);
  });

  test('should describe enforcing the coverage threshold', () {
    expect(sut.description, EnforceCoverageCommand.commandDescription);
  });

  test('should use the default lcov path and threshold when none is provided',
      () async {
    await _run(<String>[], sut);

    verify(
      // ignore: avoid_redundant_argument_values
      () => checkCoverage(lcovFile: 'coverage/lcov.info', threshold: 100),
    ).called(1);
  });

  test('should forward a supplied lcov path and threshold', () async {
    await _run(['--lcov-file=coverage/alt.info', '--threshold=90'], sut);

    verify(
      () => checkCoverage(lcovFile: 'coverage/alt.info', threshold: 90),
    ).called(1);
  });
}

Future<void> _run(List<String> args, EnforceCoverageCommand command) async {
  final runner = CommandRunner<void>('dev_tools', '')..addCommand(command);
  await runner.run(['enforce', ...args]);
}
