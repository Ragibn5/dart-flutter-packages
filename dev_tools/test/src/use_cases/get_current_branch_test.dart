import 'dart:io';

import 'package:dev_tools/src/use_cases/get_current_branch.dart';
import 'package:test/test.dart';

void main() {
  late GetCurrentBranch sut;

  setUp(() {
    sut = const GetCurrentBranch();
  });

  test(
    'should return the current branch when inside a git repository',
    () async {
      final expected = _runGit(['branch', '--show-current']);
      final branch = await sut();
      expect(branch, expected.isNotEmpty ? expected : isNull);
    },
  );
}

String _runGit(List<String> args) {
  final result = Process.runSync('git', args);
  return (result.stdout as String).trim();
}
