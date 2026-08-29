// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:base_auth_interceptor/base_auth_interceptor.dart';
import 'package:dart_functionals/dart_functionals.dart';
import 'package:mocktail/mocktail.dart';
import 'package:net_client/net_client.dart';
import 'package:test/test.dart';

class _TestAuthData {}

class _MockAuthDataProvider extends Mock
    implements AuthDataProvider<_TestAuthData> {}

class _MockRequestRetrier extends Mock
    implements RequestRetrier<_TestAuthData> {}

class _TestAuthInterceptor extends BaseAuthInterceptor<_TestAuthData> {
  final Future<RequestSpec> Function(RequestSpec, _TestAuthData) onTransform;
  final bool Function(RawResponse) onAuthError;
  final bool Function(RequestSpec, _TestAuthData) onShouldRefresh;

  _TestAuthInterceptor({
    required AuthDataProvider<_TestAuthData> provider,
    required RequestRetrier<_TestAuthData> retrier,
    required this.onTransform,
    required this.onAuthError,
    required this.onShouldRefresh,
  }) : super(provider, retrier);

  @override
  Future<RequestSpec> transformRequestWithAuthData(
    RequestSpec request,
    _TestAuthData authData,
  ) =>
      onTransform(request, authData);

  @override
  bool didServerReportAuthError(RawResponse response) => onAuthError(response);

  @override
  bool shouldRefreshAuthData(
    RequestSpec request,
    _TestAuthData authData,
  ) =>
      onShouldRefresh(request, authData);
}

void main() {
  final authData = _TestAuthData();
  final newAuthData = _TestAuthData();

  late _MockAuthDataProvider provider;
  late _MockRequestRetrier retrier;

  setUp(() {
    provider = _MockAuthDataProvider();
    retrier = _MockRequestRetrier();
    when(() => retrier.retryRequest(any(), any()))
        .thenAnswer((_) async => throw UnimplementedError());
  });

  setUpAll(() {
    registerFallbackValue(RequestSpec(pathOrUrl: '', method: HttpMethod.GET));
    registerFallbackValue(_TestAuthData());
  });

  ApiCallResult success(RequestSpec request,
          {int statusCode = HttpStatus.ok}) =>
      Success(
        NetClientResponse(
          isError: false,
          statusCode: statusCode,
          data: null,
          headers: {},
          requestSpec: request,
        ),
      );

  ApiCallResult failure() => Failure(
        CancellationException(
          source: 'test',
          message: 'retry failed',
          request: RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET),
        ),
      );

  _TestAuthInterceptor buildInterceptor(
    AuthDataProvider<_TestAuthData> provider, {
    RequestRetrier<_TestAuthData>? retrierOverride,
    Future<RequestSpec> Function(RequestSpec, _TestAuthData)? onTransform,
    bool Function(RawResponse)? onAuthError,
    bool Function(RequestSpec, _TestAuthData)? onShouldRefresh,
  }) =>
      _TestAuthInterceptor(
        provider: provider,
        retrier: retrierOverride ?? retrier,
        onTransform: onTransform ?? (request, _) async => request,
        onAuthError: onAuthError ?? (_) => false,
        onShouldRefresh: onShouldRefresh ?? (_, __) => false,
      );

  group('onRequest', () {
    test('Calls transformRequestWithAuthData and returns ContinueWithRequest',
        () async {
      when(() => provider.getAuthData()).thenAnswer((_) async => authData);

      final request = RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET);
      var transformCalled = false;
      final sut = buildInterceptor(
        provider,
        onTransform: (r, d) async {
          transformCalled = true;
          expect(d, same(authData));
          return r;
        },
      );

      final result = await sut.onRequest(request);

      expect(result, isA<ContinueWithRequest>());
      expect(transformCalled, isTrue);
      verify(() => provider.getAuthData()).called(1);
      verifyNever(() => provider.requestAuthDataRefresh(any()));
      verifyNever(() => retrier.retryRequest(any(), any()));
    });

    test(
      'Returns ShortRequestWithError when getAuthData returns null',
      () async {
        when(() => provider.getAuthData()).thenAnswer((_) async => null);

        final sut = buildInterceptor(provider);

        final request = RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET);
        final result = await sut.onRequest(request);

        expect(result, isA<ShortRequestWithError>());
        expect(
          (result as ShortRequestWithError).error,
          isA<CancellationException>(),
        );
        verify(() => provider.getAuthData()).called(1);
      },
    );
  });

  group('onResponse', () {
    test(
      'Passes through with ContinueWithResponse when didServerReportAuthError returns false',
      () async {
        when(() => provider.getAuthData()).thenAnswer((_) async => authData);

        final sut = buildInterceptor(provider);

        final response = RawResponse(
          statusCode: HttpStatus.badRequest,
          rawResponseBody: null,
          responseHeaders: {},
          request: RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET),
        );
        final result = await sut.onResponse(response);

        expect(result, isA<ContinueWithResponse>());
        verifyNever(() => provider.getAuthData());
        verifyNever(() => provider.requestAuthDataRefresh(any()));
      },
    );

    test(
      'Returns ShortResponseWithError when auth data is unavailable',
      () async {
        when(() => provider.getAuthData()).thenAnswer((_) async => null);

        final sut = buildInterceptor(
          provider,
          onAuthError: (_) => true,
        );

        final response = RawResponse(
          statusCode: HttpStatus.unauthorized,
          rawResponseBody: {'error': 'auth_error'},
          responseHeaders: {},
          request: RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET),
        );
        final result = await sut.onResponse(response);

        verify(() => provider.getAuthData()).called(1);
        expect(result, isA<ShortResponseWithError>());
        expect(
          (result as ShortResponseWithError).error,
          isA<CancellationException>(),
        );
      },
    );

    test(
      'Retries with retryRequest when shouldRefreshAuthData returns false',
      () async {
        when(() => provider.getAuthData()).thenAnswer((_) async => authData);
        when(() => retrier.retryRequest(any(), any())).thenAnswer((_) async =>
            success(RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET)));

        final sut = buildInterceptor(
          provider,
          onAuthError: (_) => true,
        );

        final response = RawResponse(
          statusCode: HttpStatus.unauthorized,
          rawResponseBody: {'error': 'auth_error'},
          responseHeaders: {},
          request: RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET),
        );
        final result = await sut.onResponse(response);

        expect(result, isA<ShortResponseWithFinalResponse>());
        verify(() => retrier.retryRequest(any(), authData)).called(1);
        verify(() => provider.getAuthData()).called(1);
        verifyNever(() => provider.requestAuthDataRefresh(any()));
      },
    );

    test(
      'Refreshes and retries when shouldRefreshAuthData returns true',
      () async {
        when(() => provider.getAuthData()).thenAnswer((_) async => authData);
        when(() => provider.requestAuthDataRefresh(authData))
            .thenAnswer((_) async => newAuthData);
        when(() => retrier.retryRequest(any(), any())).thenAnswer((_) async =>
            success(RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET)));

        final sut = buildInterceptor(
          provider,
          onAuthError: (_) => true,
          onShouldRefresh: (_, __) => true,
        );

        final response = RawResponse(
          statusCode: HttpStatus.unauthorized,
          rawResponseBody: {'error': 'auth_error'},
          responseHeaders: {},
          request: RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET),
        );
        final result = await sut.onResponse(response);

        expect(result, isA<ShortResponseWithFinalResponse>());
        verify(() => retrier.retryRequest(any(), newAuthData)).called(1);
        verify(() => provider.getAuthData()).called(1);
        verify(() => provider.requestAuthDataRefresh(authData)).called(1);
      },
    );

    test(
      'Returns ShortResponseWithError when requestAuthDataRefresh returns null',
      () async {
        when(() => provider.getAuthData()).thenAnswer((_) async => authData);
        when(() => provider.requestAuthDataRefresh(authData))
            .thenAnswer((_) async => null);

        final sut = buildInterceptor(
          provider,
          onAuthError: (_) => true,
          onShouldRefresh: (_, __) => true,
        );

        final response = RawResponse(
          statusCode: HttpStatus.unauthorized,
          rawResponseBody: {'error': 'auth_error'},
          responseHeaders: {},
          request: RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET),
        );
        final result = await sut.onResponse(response);

        expect(result, isA<ShortResponseWithError>());
        expect(
          (result as ShortResponseWithError).error,
          isA<CancellationException>(),
        );
        verify(() => provider.requestAuthDataRefresh(authData)).called(1);
      },
    );

    test(
      'Returns ShortResponseWithError when retryRequest fails '
      'in already-refreshed path',
      () async {
        when(() => provider.getAuthData()).thenAnswer((_) async => authData);
        when(() => retrier.retryRequest(any(), any()))
            .thenAnswer((_) async => failure());

        final sut = buildInterceptor(
          provider,
          onAuthError: (_) => true,
        );

        final response = RawResponse(
          statusCode: HttpStatus.unauthorized,
          rawResponseBody: {'error': 'auth_error'},
          responseHeaders: {},
          request: RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET),
        );
        final result = await sut.onResponse(response);

        expect(result, isA<ShortResponseWithError>());
        expect(
          (result as ShortResponseWithError).error,
          isA<CancellationException>(),
        );
        verifyNever(() => provider.requestAuthDataRefresh(any()));
      },
    );

    test(
      'Returns ShortResponseWithError when retryRequest fails '
      'after refresh',
      () async {
        when(() => provider.getAuthData()).thenAnswer((_) async => authData);
        when(() => provider.requestAuthDataRefresh(authData))
            .thenAnswer((_) async => newAuthData);
        when(() => retrier.retryRequest(any(), any()))
            .thenAnswer((_) async => failure());

        final sut = buildInterceptor(
          provider,
          onAuthError: (_) => true,
          onShouldRefresh: (_, __) => true,
        );

        final response = RawResponse(
          statusCode: HttpStatus.unauthorized,
          rawResponseBody: {'error': 'auth_error'},
          responseHeaders: {},
          request: RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET),
        );
        final result = await sut.onResponse(response);

        expect(result, isA<ShortResponseWithError>());
        expect(
          (result as ShortResponseWithError).error,
          isA<CancellationException>(),
        );
        verify(() => provider.requestAuthDataRefresh(authData)).called(1);
      },
    );
  });
}
