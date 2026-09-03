import 'package:dev_tools/src/exceptions/command_not_found_exception.dart';
import 'package:dev_tools/src/use_cases/cmd_installation_checker.dart';
import 'package:dev_tools/src/use_cases/fvm_aware_dart_command_finder.dart';
import 'package:test/test.dart';

class _FakeChecker extends CmdInstallationChecker {
  _FakeChecker(this.installed);

  Set<String> installed;

  @override
  Future<bool> call(String executable) async => installed.contains(executable);
}

void main() {
  late _FakeChecker cmdChecker;

  late FvmAwareDartCommandFinder sut;

  setUp(() {
    cmdChecker = _FakeChecker({});

    sut = FvmAwareDartCommandFinder(cmdInstallationChecker: cmdChecker);
  });

  test('should return fvm dart when fvm is installed', () async {
    cmdChecker.installed = {'fvm', 'dart'};

    expect(await sut(), 'fvm dart');
  });

  test('should return dart when fvm is not installed but dart is', () async {
    cmdChecker.installed = {'dart'};

    expect(await sut(), 'dart');
  });

  test(
    'should throw CommandNotFoundException when neither is installed',
    () async {
      expect(() => sut(), throwsA(isA<CommandNotFoundException>()));
    },
  );
}
