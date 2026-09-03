import 'package:dev_tools/src/exceptions/command_not_found_exception.dart';
import 'package:dev_tools/src/use_cases/cmd_installation_checker.dart';
import 'package:dev_tools/src/use_cases/fvm_aware_flutter_command_finder.dart';
import 'package:test/test.dart';

void main() {
  test('should return fvm flutter when fvm is installed', () async {
    const finder = FvmAwareFlutterCommandFinder(
      cmdInstallationChecker: _FakeChecker({'fvm', 'flutter'}),
    );
    expect(await finder(), 'fvm flutter');
  });

  test(
    'should return flutter when fvm is not installed but flutter is',
    () async {
      const finder = FvmAwareFlutterCommandFinder(
        cmdInstallationChecker: _FakeChecker({'flutter'}),
      );
      expect(await finder(), 'flutter');
    },
  );

  test(
    'should throw CommandNotFoundException when neither is installed',
    () async {
      const finder = FvmAwareFlutterCommandFinder(
        cmdInstallationChecker: _FakeChecker({}),
      );
      expect(() => finder(), throwsA(isA<CommandNotFoundException>()));
    },
  );
}

class _FakeChecker extends CmdInstallationChecker {
  const _FakeChecker(this.installed);

  final Set<String> installed;

  @override
  Future<bool> call(String executable) async => installed.contains(executable);
}
