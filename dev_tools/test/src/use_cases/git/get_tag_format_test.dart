import 'package:dev_tools/src/use_cases/git/get_tag_format.dart';
import 'package:test/test.dart';

void main() {
  group('GetTagFormat', () {
    test('should substitute the name and version placeholders', () {
      const sut = GetTagFormat();

      expect(sut(name: 'foo', version: '1.0.0'), 'foo-1.0.0');
    });

    test('should support a custom convention', () {
      const sut = GetTagFormat('{name}@{version}');

      expect(sut(name: 'foo', version: '1.0.0'), 'foo@1.0.0');
    });
  });

  group('ResolveGitTagFormat', () {
    const sut = ResolveGitTagFormat();

    test('should return the default when the env var is unset', () {
      expect(
        sut(environment: const <String, String>{}),
        defaultGitTagFormat,
      );
    });

    test('should return the env var value when it is a valid format', () {
      expect(
        sut(
          environment: const {gitTagFormatEnvVar: '{name}@{version}'},
        ),
        '{name}@{version}',
      );
    });

    test(
        'should fall back to the default when the env var is missing the '
        'name placeholder', () {
      expect(
        sut(environment: const {gitTagFormatEnvVar: 'v{version}'}),
        defaultGitTagFormat,
      );
    });

    test(
        'should fall back to the default when the env var is missing the '
        'version placeholder', () {
      expect(
        sut(environment: const {gitTagFormatEnvVar: '{name}'}),
        defaultGitTagFormat,
      );
    });

    test('should fall back to the default when the env var is empty', () {
      expect(
        sut(environment: const {gitTagFormatEnvVar: ''}),
        defaultGitTagFormat,
      );
    });
  });
}
