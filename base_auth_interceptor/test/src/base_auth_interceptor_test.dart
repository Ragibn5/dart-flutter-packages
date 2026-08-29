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

class _TestAuthInterceptor extends BaseAuthInterceptor<_TestAuthData> {
  final Future<RequestSpec> Function(RequestSpec, _TestAuthData) onTransform;
  final bool Function(RawResponse) onAuthError;
  final bool Function(RequestSpec, _TestAuthData) onShouldRefresh;
  final Future<ApiCallResult> Function(RequestSpec, _TestAuthData) onRetry;

  _TestAuthInterceptor({
    required AuthDataProvider<_TestAuthData> provider,
    required this.onTransform,
    required this.onAuthError,
    required this.onShouldRefresh,
    required this.onRetry,
  }) : super(provider);

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

  @override
  Future<ApiCallResult> retryRequest(
    RequestSpec request,
    _TestAuthData authData,
  ) =>
      onRetry(request, authData);
}

void main() {
  final authData = _TestAuthData();
  final newAuthData = _TestAuthData();

  late _MockAuthDataProvider provider;

  setUp(() {
    provider = _MockAuthDataProvider();
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
    Future<RequestSpec> Function(RequestSpec, _TestAuthData)? onTransform,
    bool Function(RawResponse)? onAuthError,
    bool Function(RequestSpec, _TestAuthData)? onShouldRefresh,
    Future<ApiCallResult> Function(RequestSpec, _TestAuthData)? onRetry,
  }) =>
      _TestAuthInterceptor(
        provider: provider,
        onTransform: onTransform ?? (request, _) async => request,
        onAuthError: onAuthError ?? (_) => false,
        onShouldRefresh: onShouldRefresh ?? (_, __) => false,
        onRetry: onRetry ?? (_, __) async => throw UnimplementedError(),
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
        onRetry: (request, _) async => success(request),
      );

      final result = await sut.onRequest(request);

      expect(result, isA<ContinueWithRequest>());
      expect(transformCalled, isTrue);
      verify(() => provider.getAuthData()).called(1);
      verifyNever(() => provider.requestAuthDataRefresh(any()));
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

        var retryCalled = false;

        final sut = buildInterceptor(
          provider,
          onAuthError: (_) => true,
          onRetry: (request, _) async {
            retryCalled = true;
            return success(request);
          },
        );

        final response = RawResponse(
          statusCode: HttpStatus.unauthorized,
          rawResponseBody: {'error': 'auth_error'},
          responseHeaders: {},
          request: RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET),
        );
        final result = await sut.onResponse(response);

        expect(result, isA<ShortResponseWithFinalResponse>());
        expect(retryCalled, isTrue);
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

        var retryCalled = false;

        final sut = buildInterceptor(
          provider,
          onAuthError: (_) => true,
          onShouldRefresh: (_, __) => true,
          onRetry: (request, _) async {
            retryCalled = true;
            return success(request);
          },
        );

        final response = RawResponse(
          statusCode: HttpStatus.unauthorized,
          rawResponseBody: {'error': 'auth_error'},
          responseHeaders: {},
          request: RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET),
        );
        final result = await sut.onResponse(response);

        expect(result, isA<ShortResponseWithFinalResponse>());
        expect(retryCalled, isTrue);
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

        final sut = buildInterceptor(
          provider,
          onAuthError: (_) => true,
          onRetry: (_, __) async => failure(),
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

        final sut = buildInterceptor(
          provider,
          onAuthError: (_) => true,
          onShouldRefresh: (_, __) => true,
          onRetry: (_, __) async => failure(),
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
