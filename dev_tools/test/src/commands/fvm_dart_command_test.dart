import 'package:dev_tools/src/commands/fvm_dart_command.dart';
import 'package:test/test.dart';

void main() {
  late FvmDartCommand sut;

  setUp(() {
    sut = FvmDartCommand();
  });

  test('should expose the fvm-dart name', () {
    expect(sut.name, FvmDartCommand.commandName);
  });

  test('should describe returning the fvm aware dart executable prefix', () {
    expect(sut.description, FvmDartCommand.commandDescription);
  });
}
