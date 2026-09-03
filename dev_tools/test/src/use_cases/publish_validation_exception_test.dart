import 'package:dev_tools/src/use_cases/publish_validation_exception.dart';
import 'package:test/test.dart';

void main() {
  test('should expose the provided message', () {
    const exception = PublishValidationException('boom');
    expect(exception.message, 'boom');
  });

  test('should be an Exception', () {
    expect(const PublishValidationException('x'), isA<Exception>());
  });
}
