import 'dart:io';

import 'package:dev_tools/src/exceptions/command_not_found_exception.dart';
import 'package:dev_tools/src/use_cases/cmd_installation_checker.dart';
import 'package:dev_tools/src/use_cases/find_project_root.dart';
import 'package:dev_tools/src/use_cases/process_coverage_data.dart';
import 'package:test/test.dart';

void main() {
  const root = '/fake/root';

  test(
    'should throw CommandNotFoundException when lcov is not installed',
    () async {
      const useCase = ProcessCoverageDataWithLcov(
        findProjectRoot: _FakeFindProjectRoot(root),
        cmdInstallationChecker: const _FakeChecker(false),
      );
      await expectLater(useCase(), throwsA(isA<CommandNotFoundException>()));
    },
  );

  test(
    'should run lcov when it is installed',
    () async {
      const useCase = ProcessCoverageDataWithLcov(
        findProjectRoot: _FakeFindProjectRoot(root),
        cmdInstallationChecker: const _FakeChecker(true),
      );
      await expectLater(useCase(exclusions: ['lib/generated/*']), completes);
    },
    skip: _toolNotAvailable('lcov') ? 'lcov not available' : null,
  );
}

class _FakeFindProjectRoot extends FindProjectRoot {
  const _FakeFindProjectRoot(this.root);

  final String root;

  @override
  Future<String> call([String? start]) async => root;
}

class _FakeChecker extends CmdInstallationChecker {
  const _FakeChecker(this.available);

  final bool available;

  @override
  Future<bool> call(String executable) async => available;
}

bool _toolNotAvailable(String tool) =>
    Process.runSync('which', [tool]).exitCode != 0;
