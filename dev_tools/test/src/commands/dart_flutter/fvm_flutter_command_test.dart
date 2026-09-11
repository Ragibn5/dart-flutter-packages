import 'package:dev_tools/src/commands/dart_flutter/fvm_flutter_command.dart';
import 'package:test/test.dart';

void main() {
  late FvmFlutterCommand sut;

  setUp(() {
    sut = FvmFlutterCommand();
  });

  test('should expose the fvm-flutter name', () {
    expect(sut.name, FvmFlutterCommand.commandName);
  });

  test('should describe returning the fvm aware flutter executable prefix', () {
    expect(sut.description, FvmFlutterCommand.commandDescription);
  });
}
