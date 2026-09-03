// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:dev_tools/src/exceptions/command_not_found_exception.dart';
import 'package:dev_tools/src/use_cases/cmd_installation_checker.dart';
import 'package:dev_tools/src/use_cases/find_project_root.dart';
import 'package:dev_tools/src/use_cases/process_coverage_data.dart';
import 'package:test/test.dart';

class _FakeFindProjectRoot extends FindProjectRoot {
  const _FakeFindProjectRoot(this.root);

  final String root;

  @override
  Future<String> call([String? start]) async => root;
}

class _FakeChecker extends CmdInstallationChecker {
  _FakeChecker({required this.available});

  bool available;

  @override
  Future<bool> call(String executable) async => available;
}

bool _toolNotAvailable(String tool) =>
    Process.runSync('which', [tool]).exitCode != 0;

void main() {
  const root = '/fake/root';

  late _FakeFindProjectRoot findProjectRoot;
  late _FakeChecker cmdChecker;

  late ProcessCoverageDataWithLcov sut;

  setUp(() {
    findProjectRoot = const _FakeFindProjectRoot(root);
    cmdChecker = _FakeChecker(available: true);

    sut = ProcessCoverageDataWithLcov(
      findProjectRoot: findProjectRoot,
      cmdInstallationChecker: cmdChecker,
    );
  });

  test(
    'should throw CommandNotFoundException when lcov is not installed',
    () async {
      cmdChecker.available = false;

      await expectLater(sut(), throwsA(isA<CommandNotFoundException>()));
    },
  );

  test(
    'should run lcov when it is installed',
    () async {
      await expectLater(sut(exclusions: ['lib/generated/*']), completes);
    },
    skip: _toolNotAvailable('lcov') ? 'lcov not available' : null,
  );
}
