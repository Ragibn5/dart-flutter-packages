import 'package:net_client/src/enums/http_method.dart';
import 'package:net_client/src/models/raw_response.dart';
import 'package:net_client/src/models/request_body.dart';
import 'package:net_client/src/models/request_spec.dart';
import 'package:net_client/src/services/mappers/response_classifier.dart';
import 'package:test/test.dart';

void main() {
  const sut = DefaultResponseClassifier();

  final request = RequestSpec(
    pathOrUrl: '/users',
    method: HttpMethod.GET,
    body: const JsonBody({}),
  );

  test('Status code below 400 returns false', () {
    final response = RawResponse(
      statusCode: 399,
      responseHeaders: {},
      rawResponseBody: null,
      request: request,
    );

    expect(sut.isError(response), isFalse);
  });

  test('Status code 400 or above returns true', () {
    final response = RawResponse(
      statusCode: 400,
      responseHeaders: {},
      rawResponseBody: null,
      request: request,
    );

    expect(sut.isError(response), isTrue);
  });

  test('Status code 0 returns false', () {
    final response = RawResponse(
      statusCode: 0,
      responseHeaders: {},
      rawResponseBody: null,
      request: request,
    );

    expect(sut.isError(response), isFalse);
  });
}
