import 'package:dev_tools/src/use_cases/common/cmd_installation_checker.dart';
import 'package:test/test.dart';

void main() {
  late CmdInstallationChecker sut;

  setUp(() {
    sut = const CmdInstallationChecker();
  });

  test('should return true when executable exists on PATH', () async {
    expect(await sut('dart'), isTrue);
  });

  test('should return false when executable does not exist on PATH', () async {
    expect(await sut('definitely_not_a_real_command_xyz'), isFalse);
  });
}
