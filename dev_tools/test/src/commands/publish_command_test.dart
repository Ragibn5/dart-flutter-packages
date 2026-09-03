import 'package:dev_tools/src/commands/publish_command.dart';
import 'package:test/test.dart';

void main() {
  test('should expose the publish name', () {
    expect(PublishCommand().name, 'publish');
  });

  test('should describe validating and publishing a package', () {
    expect(PublishCommand().description, contains('publish'));
  });
}
