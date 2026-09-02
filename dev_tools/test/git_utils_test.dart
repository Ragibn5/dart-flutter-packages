import 'package:dev_tools/dev_tools.dart';
import 'package:test/test.dart';

void main() {
  group('parseReleaseBranch', () {
    test('parses a simple release branch', () {
      final result = const GitUtils().parseReleaseBranch(
        'release/extended_string-1.0.0',
      );
      expect(result, isNotNull);
      expect(result!.packagePath, 'extended_string');
      expect(result.version, '1.0.0');
    });

    test('parses a release branch with a nested path', () {
      final result = const GitUtils().parseReleaseBranch(
        'release/packages/core_utils-2.3.4',
      );
      expect(result, isNotNull);
      expect(result!.packagePath, 'packages/core_utils');
      expect(result.version, '2.3.4');
    });

    test('returns null for a non-release branch', () {
      expect(const GitUtils().parseReleaseBranch('main'), isNull);
      expect(const GitUtils().parseReleaseBranch('release/foo'), isNull);
    });
  });
}
