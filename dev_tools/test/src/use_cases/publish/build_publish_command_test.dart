import 'package:dev_tools/src/models/package_identity.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_fvm_aware_dart_command.dart';
import 'package:dev_tools/src/use_cases/dart_flutter/find_fvm_aware_flutter_command.dart';
import 'package:dev_tools/src/use_cases/publish/build_publish_command.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockFindFvmAwareDartCommand extends Mock
    implements FindFvmAwareDartCommand {}

class _MockFindFvmAwareFlutterCommand extends Mock
    implements FindFvmAwareFlutterCommand {}

void main() {
  late _MockFindFvmAwareDartCommand findDartCommand;
  late _MockFindFvmAwareFlutterCommand findFlutterCommand;
  late BuildPublishCommand sut;

  setUp(() {
    findDartCommand = _MockFindFvmAwareDartCommand();
    findFlutterCommand = _MockFindFvmAwareFlutterCommand();
    when(() => findDartCommand()).thenAnswer((_) async => 'dart');
    when(() => findFlutterCommand()).thenAnswer((_) async => 'flutter');
    sut = BuildPublishCommand(
      findDartCommand: findDartCommand,
      findFlutterCommand: findFlutterCommand,
    );
  });

  PackageIdentity identity({required bool isFlutter}) => PackageIdentity(
        name: 'foo',
        version: '1.0.0',
        isFlutterPackage: isFlutter,
      );

  test('should use the dart finder for a dart package', () async {
    final tooling = await sut(identity(isFlutter: false));

    expect(tooling.command, 'dart');
    expect(tooling.prefix, <String>['dart']);
    expect(tooling.usesFvm, isFalse);
    verify(() => findDartCommand()).called(1);
    verifyNever(() => findFlutterCommand());
  });

  test('should use the flutter finder for a flutter package', () async {
    final tooling = await sut(identity(isFlutter: true));

    expect(tooling.command, 'flutter');
    expect(tooling.prefix, <String>['flutter']);
    expect(tooling.usesFvm, isFalse);
    verify(() => findFlutterCommand()).called(1);
    verifyNever(() => findDartCommand());
  });

  test('should forward an fvm-aware dart command', () async {
    when(() => findDartCommand()).thenAnswer((_) async => 'fvm dart');

    final tooling = await sut(identity(isFlutter: false));

    expect(tooling.command, 'fvm dart');
    expect(tooling.prefix, <String>['fvm', 'dart']);
    expect(tooling.usesFvm, isTrue);
  });

  test('should forward an fvm-aware flutter command', () async {
    when(() => findFlutterCommand()).thenAnswer((_) async => 'fvm flutter');

    final tooling = await sut(identity(isFlutter: true));

    expect(tooling.command, 'fvm flutter');
    expect(tooling.prefix, <String>['fvm', 'flutter']);
    expect(tooling.usesFvm, isTrue);
  });

  test('should tolerate extra whitespace in the resolved command', () {
    const tooling = PublishTooling('  fvm   flutter  ');

    expect(tooling.prefix, <String>['fvm', 'flutter']);
    expect(tooling.usesFvm, isTrue);
  });
}
