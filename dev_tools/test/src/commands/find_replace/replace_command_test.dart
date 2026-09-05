import 'package:args/command_runner.dart';
import 'package:dev_tools/src/commands/find_replace/replace_command.dart';
import 'package:dev_tools/src/use_cases/find_replace/replace_text_in_scope.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockReplaceTextInScope extends Mock implements ReplaceTextInScope {}

void main() {
  late ReplaceCommand sut;
  late CommandRunner<void> runner;
  late _MockReplaceTextInScope mockReplaceTextInScope;

  setUp(() {
    mockReplaceTextInScope = _MockReplaceTextInScope();
    sut = ReplaceCommand(replaceTextInScope: mockReplaceTextInScope);
    runner = CommandRunner<void>('dev_tools', 'dev tooling')..addCommand(sut);
  });

  void stubTextUtils() {
    when(() => mockReplaceTextInScope(
          srcText: any(named: 'srcText'),
          targetText: any(named: 'targetText'),
          start: any(named: 'start'),
          followLinks: any(named: 'followLinks'),
          interactive: any(named: 'interactive'),
          ignoreCase: any(named: 'ignoreCase'),
          matchWord: any(named: 'matchWord'),
          regex: any(named: 'regex'),
          exclusions: any(named: 'exclusions'),
        )).thenAnswer((_) async => 1);
  }

  test('should expose the replace name', () {
    expect(sut.name, ReplaceCommand.commandName);
  });

  test('should describe replacing literal text across files', () {
    expect(sut.description, ReplaceCommand.commandDescription);
  });

  test('should pass positionals and option flags through', () async {
    stubTextUtils();
    await runner.run([
      'replace',
      'foo',
      'bar',
      '--ignore-case',
      '--match-word',
      '--regex',
      '--yes',
      '--follow-links',
      '--start',
      'lib',
      '-e',
      'lib/generated/**',
      '-e',
      'lib/**/*.g.dart',
    ]);

    verify(() => mockReplaceTextInScope(
          srcText: 'foo',
          targetText: 'bar',
          start: 'lib',
          followLinks: true,
          interactive: false,
          ignoreCase: true,
          matchWord: true,
          regex: true,
          exclusions: ['lib/generated/**', 'lib/**/*.g.dart'],
        )).called(1);
  });

  test('should use defaults when no options are passed', () async {
    stubTextUtils();
    await runner.run(['replace', 'foo', 'bar']);

    verify(() => mockReplaceTextInScope(
          srcText: 'foo',
          targetText: 'bar',
          // ignore: avoid_redundant_argument_values
          start: null,
          // ignore: avoid_redundant_argument_values
          followLinks: false,
          // ignore: avoid_redundant_argument_values
          interactive: true,
          // ignore: avoid_redundant_argument_values
          ignoreCase: false,
          // ignore: avoid_redundant_argument_values
          matchWord: false,
          // ignore: avoid_redundant_argument_values
          regex: false,
          // ignore: avoid_redundant_argument_values
          exclusions: const [],
        )).called(1);
  });

  test('should throw UsageException when fewer than 2 positionals', () {
    expect(
      () => runner.run(['replace', 'foo']),
      throwsA(isA<UsageException>()),
    );
  });
}
