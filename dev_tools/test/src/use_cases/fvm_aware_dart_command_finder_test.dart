import 'package:dev_tools/src/exceptions/command_not_found_exception.dart';
import 'package:dev_tools/src/use_cases/cmd_installation_checker.dart';
import 'package:dev_tools/src/use_cases/fvm_aware_dart_command_finder.dart';
import 'package:test/test.dart';

void main() {
  test('should return fvm dart when fvm is installed', () async {
    const finder = FvmAwareDartCommandFinder(
      cmdInstallationChecker: _FakeChecker({'fvm', 'dart'}),
    );
    expect(await finder(), 'fvm dart');
  });

  test('should return dart when fvm is not installed but dart is', () async {
    const finder = FvmAwareDartCommandFinder(
      cmdInstallationChecker: _FakeChecker({'dart'}),
    );
    expect(await finder(), 'dart');
  });

  test(
    'should throw CommandNotFoundException when neither is installed',
    () async {
      const finder = FvmAwareDartCommandFinder(
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
