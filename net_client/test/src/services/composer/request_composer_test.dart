// ignore_for_file: avoid_redundant_argument_values, lines_longer_than_80_chars

import 'package:net_client/net_client.dart';
import 'package:net_client/src/services/composer/request_composer.dart';
import 'package:test/test.dart';

void main() {
  const testPath = '/test';
  const complexPath = '/complex';
  const sourceBaseUrl = 'https://api.source.com';
  const overrideBaseUrl = 'https://api.override.com';
  const sourceToken = 'Bearer source-token';
  const clientToken = 'Bearer client-token';
  const timeout30s = Duration(seconds: 30);
  const timeout60s = Duration(seconds: 60);
  const timeout45s = Duration(seconds: 45);
  const clientConfig = ClientConfig(
    baseUrl: 'https://api.example.com',
    sendTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 30),
    connectionTimeout: Duration(seconds: 10),
    queryParameters: {'clientParam': 'clientValue'},
    headers: {'Authorization': 'Bearer client-token'},
    followRedirects: true,
    maxRedirects: 5,
  );

  late RequestComposer sut;

  setUp(() {
    sut = const DefaultRequestComposer();
  });

  test(
    'Source values take precedence over client config for simple fields',
    () {
      final source = RequestSpec(
        pathOrUrl: testPath,
        method: HttpMethod.GET,
        baseUrl: sourceBaseUrl,
        sendTimeout: timeout60s,
        receiveTimeout: timeout60s,
        connectionTimeout: const Duration(seconds: 20),
        followRedirects: false,
        maxRedirects: 10,
      );

      final result = sut.compose(source, clientConfig);

      expect(result.baseUrl, sourceBaseUrl);
      expect(result.sendTimeout, timeout60s);
      expect(result.receiveTimeout, timeout60s);
      expect(result.connectionTimeout, const Duration(seconds: 20));
      expect(result.followRedirects, false);
      expect(result.maxRedirects, 10);
    },
  );

  test('Client config values used when source values are null', () {
    final source = RequestSpec(
      pathOrUrl: testPath,
      method: HttpMethod.GET,
    );

    final result = sut.compose(source, clientConfig);

    expect(result.baseUrl, 'https://api.example.com');
    expect(result.sendTimeout, timeout30s);
    expect(result.receiveTimeout, timeout30s);
    expect(result.connectionTimeout, const Duration(seconds: 10));
    expect(result.followRedirects, true);
    expect(result.maxRedirects, 5);
  });

  test(
    'Headers merged: source overrides conflicts, client-only headers preserved',
    () {
      const clientConfigWithExtra = ClientConfig(headers: {
        'Authorization': clientToken,
        'X-Client-Only': 'client-value',
      });
      final source = RequestSpec(
        pathOrUrl: testPath,
        method: HttpMethod.GET,
        headers: {
          'Authorization': sourceToken,
          'X-Source-Only': 'source-value',
        },
      );

      final result = sut.compose(source, clientConfigWithExtra);

      expect(result.headers, {
        'Authorization': sourceToken,
        'X-Client-Only': 'client-value',
        'X-Source-Only': 'source-value',
      });
    },
  );

  test(
    'Query parameters merged: source overrides conflicts, client-only params preserved',
    () {
      const clientConfigWithExtra = ClientConfig(queryParameters: {
        'clientParam': 'clientValue',
        'clientOnlyParam': 'clientOnlyValue',
      });
      final source = RequestSpec(
        pathOrUrl: testPath,
        method: HttpMethod.GET,
        queryParameters: {
          'clientParam': 'sourceOverridden',
          'sourceOnlyParam': 'sourceValue',
        },
      );

      final result = sut.compose(source, clientConfigWithExtra);

      expect(result.queryParameters, {
        'clientParam': 'sourceOverridden',
        'clientOnlyParam': 'clientOnlyValue',
        'sourceOnlyParam': 'sourceValue',
      });
    },
  );

  test('Null source and config values default to empty maps and nulls', () {
    const emptyConfig = ClientConfig();
    final source = RequestSpec(pathOrUrl: testPath, method: HttpMethod.GET);

    final result = sut.compose(source, emptyConfig);

    expect(result.baseUrl, null);
    expect(result.sendTimeout, null);
    expect(result.receiveTimeout, null);
    expect(result.connectionTimeout, null);
    expect(result.headers, <String, dynamic>{});
    expect(result.queryParameters, <String, dynamic>{});
    expect(result.followRedirects, true);
    expect(result.maxRedirects, 5);
  });

  test('Source empty maps inherit client config maps', () {
    final source = RequestSpec(
      pathOrUrl: testPath,
      method: HttpMethod.GET,
      headers: {},
      queryParameters: {},
    );

    final result = sut.compose(source, clientConfig);

    expect(result.headers, {'Authorization': clientToken});
    expect(result.queryParameters, {'clientParam': 'clientValue'});
  });

  test('Source overrides and merges with client config simultaneously', () {
    final source = RequestSpec(
      pathOrUrl: complexPath,
      method: HttpMethod.POST,
      baseUrl: overrideBaseUrl,
      sendTimeout: timeout45s,
      headers: {'X-Custom': 'header'},
      queryParameters: {'filter': 'active'},
      followRedirects: false,
    );

    final result = sut.compose(source, clientConfig);

    expect(result.baseUrl, overrideBaseUrl);
    expect(result.sendTimeout, timeout45s);
    expect(result.receiveTimeout, timeout30s);
    expect(result.followRedirects, false);
    expect(result.headers, {
      'X-Custom': 'header',
      'Authorization': clientToken,
    });
    expect(result.queryParameters, {
      'filter': 'active',
      'clientParam': 'clientValue',
    });
  });
}
