import 'package:dev_tools/src/use_cases/release/release_validation_exception.dart';
import 'package:test/test.dart';

void main() {
  test('should expose the provided message', () {
    const exception = ReleaseValidationException('boom');
    expect(exception.message, 'boom');
  });

  test('should be an Exception', () {
    expect(const ReleaseValidationException('x'), isA<Exception>());
  });
}
