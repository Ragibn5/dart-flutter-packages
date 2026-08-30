// ignore_for_file: avoid_redundant_argument_values

import 'package:net_client/src/clients/dio/dio_factory.dart';
import 'package:net_client/src/models/client_config.dart';
import 'package:test/test.dart';

void main() {
  late DioFactory sut;

  setUp(() {
    sut = const DioFactory();
  });

  test(
    'createDio assigns empty string if default config has null base url',
    () {
      const config = ClientConfig(baseUrl: null);

      final dio = sut.createDio(config);

      expect(dio.options.baseUrl, isEmpty);
    },
  );

  test('createDio passes through same values from config', () {
    const baseUrl = 'https://example.com/api';
    const connectionTimeout = Duration(seconds: 10);
    const sendTimeout = Duration(seconds: 10);
    const receiveTimeout = Duration(seconds: 10);
    const queryParameters = {'foo': 'bar'};
    const headers = {'foo': 'bar'};
    const followRedirects = true;
    const maxRedirects = 10;
    const config = ClientConfig(
      baseUrl: baseUrl,
      connectionTimeout: connectionTimeout,
      sendTimeout: sendTimeout,
      receiveTimeout: receiveTimeout,
      queryParameters: queryParameters,
      headers: headers,
      followRedirects: followRedirects,
      maxRedirects: maxRedirects,
    );

    final dio = sut.createDio(config);

    expect(dio.options.baseUrl, config.baseUrl);
    expect(dio.options.connectTimeout, config.connectionTimeout);
    expect(dio.options.sendTimeout, config.sendTimeout);
    expect(dio.options.receiveTimeout, config.receiveTimeout);
    expect(dio.options.queryParameters, config.queryParameters);
    expect(dio.options.headers, config.headers);
    expect(dio.options.followRedirects, config.followRedirects);
    expect(dio.options.maxRedirects, config.maxRedirects);
  });
}
