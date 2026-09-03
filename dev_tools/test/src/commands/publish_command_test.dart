import 'package:dev_tools/src/commands/publish_command.dart';
import 'package:test/test.dart';

void main() {
  late PublishCommand sut;

  setUp(() {
    sut = PublishCommand();
  });

  test('should expose the publish name', () {
    expect(sut.name, 'publish');
  });

  test('should describe validating and publishing a package', () {
    expect(sut.description, contains('publish'));
  });
}
