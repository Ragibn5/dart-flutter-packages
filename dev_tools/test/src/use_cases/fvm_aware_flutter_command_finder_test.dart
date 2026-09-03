import 'package:dev_tools/src/exceptions/command_not_found_exception.dart';
import 'package:dev_tools/src/use_cases/cmd_installation_checker.dart';
import 'package:dev_tools/src/use_cases/fvm_aware_flutter_command_finder.dart';
import 'package:test/test.dart';

class _FakeChecker extends CmdInstallationChecker {
  _FakeChecker(this.installed);

  Set<String> installed;

  @override
  Future<bool> call(String executable) async => installed.contains(executable);
}

void main() {
  late _FakeChecker cmdChecker;

  late FvmAwareFlutterCommandFinder sut;

  setUp(() {
    cmdChecker = _FakeChecker({});

    sut = FvmAwareFlutterCommandFinder(cmdInstallationChecker: cmdChecker);
  });

  test('should return fvm flutter when fvm is installed', () async {
    cmdChecker.installed = {'fvm', 'flutter'};

    expect(await sut(), 'fvm flutter');
  });

  test(
    'should return flutter when fvm is not installed but flutter is',
    () async {
      cmdChecker.installed = {'flutter'};

      expect(await sut(), 'flutter');
    },
  );

  test(
    'should throw CommandNotFoundException when neither is installed',
    () async {
      expect(() => sut(), throwsA(isA<CommandNotFoundException>()));
    },
  );
}
