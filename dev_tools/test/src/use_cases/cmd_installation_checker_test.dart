import 'package:dev_tools/src/use_cases/cmd_installation_checker.dart';
import 'package:test/test.dart';

void main() {
  const useCase = CmdInstallationChecker();

  test('should return true when executable exists on PATH', () async {
    expect(await useCase('dart'), isTrue);
  });

  test('should return false when executable does not exist on PATH', () async {
    expect(await useCase('definitely_not_a_real_command_xyz'), isFalse);
  });
}
