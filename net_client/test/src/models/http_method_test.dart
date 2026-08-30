import 'package:net_client/src/enums/http_method.dart';
import 'package:test/test.dart';

void main() {
  test('Returns the matching method for normalized input', () {
    expect(HttpMethod.fromValue(' post '), HttpMethod.POST);
  });

  test('Returns HEAD for normalized HEAD input', () {
    expect(HttpMethod.fromValue(' head '), HttpMethod.HEAD);
  });

  test('Throws for an unsupported method', () {
    expect(() => HttpMethod.fromValue('TRACE'), throwsA(isA<ArgumentError>()));
  });
}
