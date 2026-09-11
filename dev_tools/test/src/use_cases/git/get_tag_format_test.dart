import 'package:dev_tools/src/use_cases/git/get_tag_format.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockResolveGitTagFormat extends Mock implements ResolveGitTagFormat {}

void main() {
  group('GetTagFormat', () {
    late _MockResolveGitTagFormat resolveGitTagFormat;
    late GetTagFormat sut;

    setUp(() {
      resolveGitTagFormat = _MockResolveGitTagFormat();
      sut = GetTagFormat(resolveGitTagFormat);
    });

    test(
        'should substitute the name and version placeholders into the '
        'resolved format', () {
      when(() => resolveGitTagFormat()).thenReturn('{name}-{version}');

      expect(sut(name: 'foo', version: '1.0.0'), 'foo-1.0.0');
    });

    test('should support a custom resolved convention', () {
      when(() => resolveGitTagFormat()).thenReturn('{name}@{version}');

      expect(sut(name: 'foo', version: '1.0.0'), 'foo@1.0.0');
    });

    test('should resolve the format fresh on every call', () {
      when(() => resolveGitTagFormat()).thenReturn('{name}-{version}');

      sut(name: 'foo', version: '1.0.0');
      sut(name: 'bar', version: '2.0.0');

      verify(() => resolveGitTagFormat()).called(2);
    });
  });

  group('ResolveGitTagFormat', () {
    const sut = ResolveGitTagFormat();

    test('should return the default when the env var is unset', () {
      expect(
        sut(environment: const <String, String>{}),
        ResolveGitTagFormat.defaultGitTagFormat,
      );
    });

    test('should return the env var value when it is a valid format', () {
      expect(
        sut(
          environment: const {
            ResolveGitTagFormat.gitTagFormatEnvVar: '{name}@{version}',
          },
        ),
        '{name}@{version}',
      );
    });

    test(
        'should fall back to the default when the env var is missing the '
        'name placeholder', () {
      expect(
        sut(
          environment: const {
            ResolveGitTagFormat.gitTagFormatEnvVar: 'v{version}',
          },
        ),
        ResolveGitTagFormat.defaultGitTagFormat,
      );
    });

    test(
        'should fall back to the default when the env var is missing the '
        'version placeholder', () {
      expect(
        sut(
          environment: const {
            ResolveGitTagFormat.gitTagFormatEnvVar: '{name}',
          },
        ),
        ResolveGitTagFormat.defaultGitTagFormat,
      );
    });

    test('should fall back to the default when the env var is empty', () {
      expect(
        sut(
          environment: const {ResolveGitTagFormat.gitTagFormatEnvVar: ''},
        ),
        ResolveGitTagFormat.defaultGitTagFormat,
      );
    });
  });
}
