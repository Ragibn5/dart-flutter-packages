import 'package:dev_tools/src/exceptions/command_not_found_exception.dart';
import 'package:dev_tools/src/use_cases/cmd_installation_checker.dart';
import 'package:dev_tools/src/use_cases/fvm_aware_flutter_command_finder.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockCmdChecker extends Mock implements CmdInstallationChecker {}

void main() {
  late _MockCmdChecker cmdChecker;

  late FvmAwareFlutterCommandFinder sut;

  setUp(() {
    cmdChecker = _MockCmdChecker();

    sut = FvmAwareFlutterCommandFinder(cmdInstallationChecker: cmdChecker);
  });

  test('should return fvm flutter when fvm is installed', () async {
    when(() => cmdChecker('fvm')).thenAnswer((_) async => true);
    when(() => cmdChecker('flutter')).thenAnswer((_) async => true);

    expect(await sut(), 'fvm flutter');
  });

  test(
    'should return flutter when fvm is not installed but flutter is',
    () async {
      when(() => cmdChecker('fvm')).thenAnswer((_) async => false);
      when(() => cmdChecker('flutter')).thenAnswer((_) async => true);

      expect(await sut(), 'flutter');
    },
  );

  test(
    'should throw CommandNotFoundException when neither is installed',
    () async {
      when(() => cmdChecker('fvm')).thenAnswer((_) async => false);
      when(() => cmdChecker('flutter')).thenAnswer((_) async => false);

      expect(() => sut(), throwsA(isA<CommandNotFoundException>()));
    },
  );
}
