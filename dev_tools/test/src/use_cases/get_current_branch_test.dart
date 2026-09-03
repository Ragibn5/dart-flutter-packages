import 'dart:io';

import 'package:dev_tools/src/use_cases/get_current_branch.dart';
import 'package:test/test.dart';

void main() {
  const useCase = GetCurrentBranch();

  test(
    'should return the current branch when inside a git repository',
    () async {
      final expected = _runGit(['branch', '--show-current']);
      final branch = await useCase();
      expect(branch, expected.isNotEmpty ? expected : isNull);
    },
  );
}

String _runGit(List<String> args) {
  final result = Process.runSync('git', args);
  return (result.stdout as String).trim();
}
