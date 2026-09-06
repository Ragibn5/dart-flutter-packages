import 'dart:io';

import 'package:dev_tools/src/use_cases/publish/read_package_identity.dart';
import 'package:test/test.dart';

void main() {
  const pkgPath = 'pkg';

  late Directory tempDir;

  late ReadPackageIdentity sut;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('read_package_identity_test');
    Directory('${tempDir.path}/$pkgPath').createSync(recursive: true);

    sut = const ReadPackageIdentity();
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  test('should return the package identity from pubspec.yaml', () async {
    File('${tempDir.path}/$pkgPath/pubspec.yaml')
        .writeAsStringSync('name: foo\nversion: 1.0.0\n');

    final identity = await sut(tempDir.path, pkgPath);

    expect(identity.name, 'foo');
    expect(identity.version, '1.0.0');
    expect(identity.isFlutterPackage, isFalse);
  });

  test('should mark a package as Flutter from an environment.flutter row',
      () async {
    File('${tempDir.path}/$pkgPath/pubspec.yaml').writeAsStringSync('''
name: foo
version: 1.0.0
environment:
  sdk: ^3.0.0
  flutter: ">=3.3.0"
''');

    final identity = await sut(tempDir.path, pkgPath);

    expect(identity.isFlutterPackage, isTrue);
  });

  test('should mark a package as Flutter from a dependency on the flutter SDK',
      () async {
    File('${tempDir.path}/$pkgPath/pubspec.yaml').writeAsStringSync('''
name: foo
version: 1.0.0
dependencies:
  flutter:
    sdk: flutter
''');

    final identity = await sut(tempDir.path, pkgPath);

    expect(identity.isFlutterPackage, isTrue);
  });

  test(
      'should mark a package as Flutter from a dev_dependency on the '
      'flutter SDK', () async {
    File('${tempDir.path}/$pkgPath/pubspec.yaml').writeAsStringSync('''
    name: foo
    version: 1.0.0
    dev_dependencies:
      flutter:
        sdk: flutter
    ''');

    final identity = await sut(tempDir.path, pkgPath);

    expect(identity.isFlutterPackage, isTrue);
  });

  test('should mark a package as Flutter from a top-level flutter section',
      () async {
    File('${tempDir.path}/$pkgPath/pubspec.yaml').writeAsStringSync('''
name: foo
version: 1.0.0
flutter:
  plugin: true
''');

    final identity = await sut(tempDir.path, pkgPath);

    expect(identity.isFlutterPackage, isTrue);
  });

  test('should throw PackageIdentityException when pubspec.yaml is missing',
      () async {
    await expectLater(
      sut(tempDir.path, pkgPath),
      throwsA(
        isA<PackageIdentityException>().having(
          (e) => e.message,
          'message',
          'Error: pubspec.yaml not found.',
        ),
      ),
    );
  });

  test('should throw PackageIdentityException when pubspec has no name',
      () async {
    File('${tempDir.path}/$pkgPath/pubspec.yaml')
        .writeAsStringSync('version: 1.0.0\n');

    await expectLater(
      sut(tempDir.path, pkgPath),
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
      () async {
    File('${tempDir.path}/$pkgPath/pubspec.yaml')
        .writeAsStringSync('name: foo\n');

    await expectLater(
      sut(tempDir.path, pkgPath),
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
