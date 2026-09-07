import 'package:dev_tools/src/use_cases/publish/parse_pubspec_content.dart';
import 'package:test/test.dart';

void main() {
  late ParsePubspecContent sut;

  setUp(() {
    sut = const ParsePubspecContent();
  });

  test('should return the package identity from pubspec.yaml content', () {
    final identity = sut('name: foo\nversion: 1.0.0\n');

    expect(identity.name, 'foo');
    expect(identity.version, '1.0.0');
    expect(identity.isFlutterPackage, isFalse);
  });

  test('should mark a package as Flutter from an environment.flutter row',
      () {
    final identity = sut('''
name: foo
version: 1.0.0
environment:
  sdk: ^3.0.0
  flutter: ">=3.3.0"
''');

    expect(identity.isFlutterPackage, isTrue);
  });

  test('should mark a package as Flutter from a dependency on the flutter SDK',
      () {
    final identity = sut('''
name: foo
version: 1.0.0
dependencies:
  flutter:
    sdk: flutter
''');

    expect(identity.isFlutterPackage, isTrue);
  });

  test(
      'should mark a package as Flutter from a dev_dependency on the '
      'flutter SDK', () {
    final identity = sut('''
    name: foo
    version: 1.0.0
    dev_dependencies:
      flutter:
        sdk: flutter
    ''');

    expect(identity.isFlutterPackage, isTrue);
  });

  test('should mark a package as Flutter from a top-level flutter section',
      () {
    final identity = sut('''
name: foo
version: 1.0.0
flutter:
  plugin: true
''');

    expect(identity.isFlutterPackage, isTrue);
  });

  test('should throw PackageIdentityException when pubspec has no name', () {
    expect(
      () => sut('version: 1.0.0\n'),
      throwsA(
        isA<PackageIdentityException>().having(
          (e) => e.message,
          'message',
          'Error: pubspec.yaml has no name.',
        ),
      ),
    );
  });

  test('should throw PackageIdentityException when pubspec has no version',
      () {
    expect(
      () => sut('name: foo\n'),
      throwsA(
        isA<PackageIdentityException>().having(
          (e) => e.message,
          'message',
          'Error: pubspec.yaml has no version.',
        ),
      ),
    );
  });
}
