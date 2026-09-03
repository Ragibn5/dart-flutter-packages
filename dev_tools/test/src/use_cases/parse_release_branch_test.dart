import 'package:dev_tools/src/use_cases/parse_release_branch.dart';
import 'package:test/test.dart';

void main() {
  const useCase = ParseReleaseBranch();

  test(
    'should return parsed package path and version when branch is a simple release branch',
    () {
      final result = useCase('release/extended_string-1.0.0');
      expect(result, isNotNull);
      expect(result!.packagePath, 'extended_string');
      expect(result.version, '1.0.0');
    },
  );

  test(
    'should return parsed nested package path when branch contains slashes',
    () {
      final result = useCase('release/packages/core_utils-2.3.4');
      expect(result, isNotNull);
      expect(result!.packagePath, 'packages/core_utils');
      expect(result.version, '2.3.4');
    },
  );

  test('should return null when branch does not start with release prefix', () {
    expect(useCase('main'), isNull);
  });

  test('should return null when branch has no version suffix', () {
    expect(useCase('release/foo'), isNull);
  });

  test('should return null when branch version is not semantic', () {
    expect(useCase('release/foo-1.2'), isNull);
  });
}
