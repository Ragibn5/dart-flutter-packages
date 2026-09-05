import 'package:dev_tools/src/exceptions/command_not_found_exception.dart';
import 'package:dev_tools/src/use_cases/common/cmd_installation_checker.dart';
import 'package:dev_tools/src/use_cases/common/find_fvm_aware_dart_command.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockCmdChecker extends Mock implements CmdInstallationChecker {}

void main() {
  late _MockCmdChecker cmdChecker;

  late FindFvmAwareDartCommand sut;

  setUp(() {
    cmdChecker = _MockCmdChecker();

    sut = FindFvmAwareDartCommand(cmdInstallationChecker: cmdChecker);
  });

  test('should return fvm dart when fvm is installed', () async {
    when(() => cmdChecker('fvm')).thenAnswer((_) async => true);
    when(() => cmdChecker('dart')).thenAnswer((_) async => true);

    expect(await sut(), 'fvm dart');
  });

  test('should return dart when fvm is not installed but dart is', () async {
    when(() => cmdChecker('fvm')).thenAnswer((_) async => false);
    when(() => cmdChecker('dart')).thenAnswer((_) async => true);

    expect(await sut(), 'dart');
  });

  test(
    'should throw CommandNotFoundException when neither is installed',
    () async {
      when(() => cmdChecker('fvm')).thenAnswer((_) async => false);
      when(() => cmdChecker('dart')).thenAnswer((_) async => false);

      expect(() => sut(), throwsA(isA<CommandNotFoundException>()));
    },
  );
}
