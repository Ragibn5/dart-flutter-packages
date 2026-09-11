import 'package:args/command_runner.dart';
import 'package:dev_tools/src/commands/coverage/process_coverage_command.dart';
import 'package:dev_tools/src/use_cases/coverage/process_coverage_data.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockProcessCoverageDataWithLcov extends Mock
    implements ProcessCoverageDataWithLcov {}

void main() {
  late _MockProcessCoverageDataWithLcov processCoverageData;
  late ProcessCoverageCommand sut;

  setUp(() {
    processCoverageData = _MockProcessCoverageDataWithLcov();
    when(() => processCoverageData(exclusions: any(named: 'exclusions')))
        .thenAnswer((_) async {});
    sut = ProcessCoverageCommand(processCoverageData: processCoverageData);
  });

  test('should expose the process name', () {
    expect(sut.name, ProcessCoverageCommand.commandName);
  });

  test('should describe filtering lcov data using exclusion patterns', () {
    expect(sut.description, ProcessCoverageCommand.commandDescription);
  });

  test('should pass no exclusions when none are provided', () async {
    await _run(<String>[], sut);

    // ignore: avoid_redundant_argument_values
    verify(() => processCoverageData(exclusions: const [])).called(1);
  });

  test('should forward supplied exclusions', () async {
    await _run(['--exclude=lib/api/**', '-elib/generated/**'], sut);

    verify(() => processCoverageData(exclusions: [
          'lib/api/**',
          'lib/generated/**',
        ])).called(1);
  });
}

Future<void> _run(List<String> args, ProcessCoverageCommand command) async {
  final runner = CommandRunner<void>('dev_tools', '')..addCommand(command);
  await runner.run(['process', ...args]);
}
