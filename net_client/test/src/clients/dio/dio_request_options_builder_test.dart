// ignore_for_file: lines_longer_than_80_chars, avoid_redundant_argument_values

import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:net_client/src/clients/dio/dio_cancel_token_builder.dart';
import 'package:net_client/src/clients/dio/dio_request_body_transformer.dart';
import 'package:net_client/src/clients/dio/dio_request_options_builder.dart';
import 'package:net_client/src/enums/http_method.dart';
import 'package:net_client/src/models/request_body.dart';
import 'package:net_client/src/models/request_spec.dart';
import 'package:net_client/src/services/cancellation/request_canceller.dart';
import 'package:net_client/src/services/mappers/response_status_validator.dart';
import 'package:test/test.dart';

class _MockResponseStatusValidator extends Mock
    implements ResponseStatusValidator {}

class _MockDioCancelTokenBuilder extends Mock
    implements DioCancelTokenBuilder {}

class _MockDioRequestBodyTransformer extends Mock
    implements DioRequestBodyTransformer {}

void main() {
  const path = 'p';
  const method = HttpMethod.GET;
  const sendTimeout = Duration(seconds: 2);
  const receiveTimeout = Duration(seconds: 3);
  const connectionTimeout = Duration(seconds: 4);
  const queryParameters = {'page': 1};
  const baseUrl = 'https://example.com/api';
  const headers = {'authorization': 'Bearer token'};
  const followRedirects = true;
  const maxRedirects = 10;
  const requestBody = JsonBody({});
  const validateStatus = true;
  final dioCancelToken = CancelToken();
  final requestCanceller = RequestCanceller();
  final requestSpec = RequestSpec(
    pathOrUrl: path,
    method: method,
    body: requestBody,
    queryParameters: queryParameters,
    headers: headers,
    baseUrl: baseUrl,
    sendTimeout: sendTimeout,
    receiveTimeout: receiveTimeout,
    connectionTimeout: connectionTimeout,
    followRedirects: followRedirects,
    maxRedirects: maxRedirects,
  );
  void onSendProgress(int count, int total) {}
  void onReceiveProgress(int count, int total) {}

  late _MockResponseStatusValidator mockResponseStatusValidator;
  late _MockDioCancelTokenBuilder mockDioCancelTokenBuilder;
  late _MockDioRequestBodyTransformer mockDioRequestBodyTransformer;

  late DioRequestOptionsBuilder sut;

  setUpAll(() {
    registerFallbackValue(requestBody);
    registerFallbackValue(dioCancelToken);
    registerFallbackValue(requestCanceller);
  });

  setUp(() {
    mockResponseStatusValidator = _MockResponseStatusValidator();
    mockDioCancelTokenBuilder = _MockDioCancelTokenBuilder();
    mockDioRequestBodyTransformer = _MockDioRequestBodyTransformer();

    sut = DioRequestOptionsBuilder(
      mockResponseStatusValidator,
      mockDioCancelTokenBuilder,
      mockDioRequestBodyTransformer,
    );

    when(() => mockDioRequestBodyTransformer.transform(requestSpec.body))
        .thenReturn(requestBody.data);
    when(() => mockDioCancelTokenBuilder.create(requestSpec, requestCanceller))
        .thenReturn(dioCancelToken);
    when(() => mockResponseStatusValidator.validateStatus(any()))
        .thenReturn(validateStatus);
  });

  test('build creates a Dio request options with correct values', () {
    final result = sut.build(
      spec: requestSpec,
      canceller: requestCanceller,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );

    expect(result.path, requestSpec.pathOrUrl);
    expect(result.data, requestBody.data);
    expect(result.method, requestSpec.method.value);
    expect(result.contentType, requestSpec.body?.contentType);
    expect(result.cancelToken, dioCancelToken);
    expect(result.sendTimeout, requestSpec.sendTimeout);
    expect(result.receiveTimeout, requestSpec.receiveTimeout);
    expect(result.connectTimeout, requestSpec.connectionTimeout);
    requestSpec.queryParameters.forEach((key, value) {
      expect(result.queryParameters.containsKey(key), isTrue);
      expect(result.queryParameters[key], value);
    });
    requestSpec.headers.forEach((key, value) {
      expect(result.headers.containsKey(key), isTrue);
      expect(result.headers[key], value);
    });
    expect(result.baseUrl, requestSpec.baseUrl);
    expect(result.followRedirects, requestSpec.followRedirects);
    expect(result.maxRedirects, requestSpec.maxRedirects);
    expect(result.onSendProgress, onSendProgress);
    expect(result.onReceiveProgress, onReceiveProgress);
    expect(result.validateStatus(200), validateStatus);
  });
}
