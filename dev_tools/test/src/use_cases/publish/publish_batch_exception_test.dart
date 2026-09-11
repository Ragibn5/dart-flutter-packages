import 'package:dev_tools/src/use_cases/publish/publish_batch_exception.dart';
import 'package:test/test.dart';

void main() {
  test('should expose the provided message', () {
    const exception = PublishBatchException('boom');
    expect(exception.message, 'boom');
  });

  test('should be an Exception', () {
    expect(const PublishBatchException('x'), isA<Exception>());
  });
}
