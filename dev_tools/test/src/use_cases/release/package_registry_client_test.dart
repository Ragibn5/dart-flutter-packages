import 'package:dev_tools/src/use_cases/release/package_registry_client.dart';
import 'package:test/test.dart';

void main() {
  test('should expose the provided message', () {
    const exception = PackageRegistryLookupException('boom');
    expect(exception.message, 'boom');
  });

  test('should be an Exception', () {
    expect(const PackageRegistryLookupException('x'), isA<Exception>());
  });
}
