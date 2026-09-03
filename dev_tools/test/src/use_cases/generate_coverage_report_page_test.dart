import 'dart:io';

import 'package:dev_tools/src/exceptions/command_not_found_exception.dart';
import 'package:dev_tools/src/use_cases/cmd_installation_checker.dart';
import 'package:dev_tools/src/use_cases/find_project_root.dart';
import 'package:dev_tools/src/use_cases/generate_coverage_report_page.dart';
import 'package:test/test.dart';

void main() {
  const root = '/fake/root';

  late _FakeFindProjectRoot findProjectRoot;
  late _FakeChecker cmdChecker;

  late GenerateCoverageReportPage sut;

  setUp(() {
    findProjectRoot = _FakeFindProjectRoot(root);
    cmdChecker = _FakeChecker(true);

    sut = GenerateCoverageReportPage(
      findProjectRoot: findProjectRoot,
      cmdInstallationChecker: cmdChecker,
    );
  });

  test(
    'should throw CommandNotFoundException when genhtml is not installed',
    () async {
      cmdChecker.available = false;

      await expectLater(sut(), throwsA(isA<CommandNotFoundException>()));
    },
  );

  test(
    'should run genhtml when it is installed',
    () async {
      await expectLater(sut(), completes);
    },
    skip: _toolNotAvailable('genhtml') ? 'genhtml not available' : null,
  );
}

class _FakeFindProjectRoot extends FindProjectRoot {
  const _FakeFindProjectRoot(this.root);

  final String root;

  @override
  Future<String> call([String? start]) async => root;
}

class _FakeChecker extends CmdInstallationChecker {
  _FakeChecker(this.available);

  bool available;

  @override
  Future<bool> call(String executable) async => available;
}

bool _toolNotAvailable(String tool) =>
    Process.runSync('which', [tool]).exitCode != 0;
