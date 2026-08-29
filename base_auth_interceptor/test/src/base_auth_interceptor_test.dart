// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:base_auth_interceptor/base_auth_interceptor.dart';
import 'package:dart_functionals/dart_functionals.dart';
import 'package:mocktail/mocktail.dart';
import 'package:net_client/net_client.dart';
import 'package:test/test.dart';

class _TestAuthData {}

class _TestAuthInterceptor extends BaseAuthInterceptor<_TestAuthData> {
  final Future<_TestAuthData?> Function() onGetAuthData;
  final Future<RequestSpec> Function(RequestSpec, _TestAuthData) onTransform;
  final bool Function(RawResponse) onAuthError;
  final bool Function(RequestSpec, _TestAuthData) onShouldRefresh;
  final Future<_TestAuthData?> Function(_TestAuthData) onRefresh;
  final Future<ApiCallResult> Function(RequestSpec, _TestAuthData) onRetry;

  _TestAuthInterceptor({
    required this.onGetAuthData,
    required this.onTransform,
    required this.onAuthError,
    required this.onShouldRefresh,
    required this.onRefresh,
    required this.onRetry,
  });

  @override
  Future<_TestAuthData?> getAuthData() => onGetAuthData();

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
  Future<_TestAuthData?> requestAuthDataRefresh(
    _TestAuthData oldAuthData,
  ) =>
      onRefresh(oldAuthData);

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

  setUpAll(() {
    registerFallbackValue(RequestSpec(pathOrUrl: '', method: HttpMethod.GET));
  });

  group('onRequest', () {
    test('Calls transformRequestWithAuthData and returns ContinueWithRequest',
        () async {
      final request = RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET);
      var transformCalled = false;

      final sut = _TestAuthInterceptor(
        onGetAuthData: () async => authData,
        onTransform: (r, d) async {
          transformCalled = true;
          expect(d, same(authData));
          return r;
        },
        onAuthError: (_) => false,
        onShouldRefresh: (_, __) => false,
        onRefresh: (_) async => null,
        onRetry: (_, __) async => Success(
          NetClientResponse(
            isError: false,
            statusCode: HttpStatus.ok,
            data: null,
            headers: {},
            requestSpec: request,
          ),
        ),
      );

      final result = await sut.onRequest(request);

      expect(result, isA<ContinueWithRequest>());
      expect(transformCalled, isTrue);
    });

    test(
      'Returns ShortRequestWithError when getAuthData returns null',
      () async {
        final sut = _TestAuthInterceptor(
          onGetAuthData: () async => null,
          onTransform: (_, __) async => throw UnimplementedError(),
          onAuthError: (_) => false,
          onShouldRefresh: (_, __) => false,
          onRefresh: (_) async => null,
          onRetry: (_, __) async => throw UnimplementedError(),
        );

        final request = RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET);
        final result = await sut.onRequest(request);

        expect(result, isA<ShortRequestWithError>());
        expect(
          (result as ShortRequestWithError).error,
          isA<CancellationException>(),
        );
      },
    );
  });

  group('onResponse', () {
    test(
      'Passes through with ContinueWithResponse when didServerReportAuthError returns false',
      () async {
        final sut = _TestAuthInterceptor(
          onGetAuthData: () async => authData,
          onTransform: (r, _) async => r,
          onAuthError: (_) => false,
          onShouldRefresh: (_, __) => false,
          onRefresh: (_) async => null,
          onRetry: (_, __) async => throw UnimplementedError(),
        );

        final response = RawResponse(
          statusCode: HttpStatus.badRequest,
          rawResponseBody: null,
          responseHeaders: {},
          request: RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET),
        );
        final result = await sut.onResponse(response);

        expect(result, isA<ContinueWithResponse>());
      },
    );

    test(
      'Returns ShortResponseWithError when auth data is unavailable',
      () async {
        final sut = _TestAuthInterceptor(
          onGetAuthData: () async => null,
          onTransform: (_, __) async => throw UnimplementedError(),
          onAuthError: (_) => true,
          onShouldRefresh: (_, __) => false,
          onRefresh: (_) async => null,
          onRetry: (_, __) async => throw UnimplementedError(),
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
      },
    );

    test(
      'Retries with retryRequest when shouldRefreshAuthData returns false',
      () async {
        var retryCalled = false;

        final sut = _TestAuthInterceptor(
          onGetAuthData: () async => authData,
          onTransform: (r, _) async => r,
          onAuthError: (_) => true,
          onShouldRefresh: (_, __) => false,
          onRefresh: (_) async => throw UnimplementedError(),
          onRetry: (_, __) async {
            retryCalled = true;
            return Success(
              NetClientResponse(
                isError: false,
                statusCode: HttpStatus.ok,
                data: null,
                headers: {},
                requestSpec: RequestSpec(
                  pathOrUrl: '/test',
                  method: HttpMethod.GET,
                ),
              ),
            );
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
      },
    );

    test(
      'Refreshes and retries when shouldRefreshAuthData returns true',
      () async {
        var refreshCalled = false;
        var retryCalled = false;

        final sut = _TestAuthInterceptor(
          onGetAuthData: () async => authData,
          onTransform: (r, _) async => r,
          onAuthError: (_) => true,
          onShouldRefresh: (_, __) => true,
          onRefresh: (_) async {
            refreshCalled = true;
            return newAuthData;
          },
          onRetry: (_, __) async {
            retryCalled = true;
            return Success(
              NetClientResponse(
                isError: false,
                statusCode: HttpStatus.ok,
                data: null,
                headers: {},
                requestSpec: RequestSpec(
                  pathOrUrl: '/test',
                  method: HttpMethod.GET,
                ),
              ),
            );
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
        expect(refreshCalled, isTrue);
        expect(retryCalled, isTrue);
      },
    );

    test(
      'Returns ShortResponseWithError when requestAuthDataRefresh returns null',
      () async {
        var refreshCalled = false;

        final sut = _TestAuthInterceptor(
          onGetAuthData: () async => authData,
          onTransform: (r, _) async => r,
          onAuthError: (_) => true,
          onShouldRefresh: (_, __) => true,
          onRefresh: (_) async {
            refreshCalled = true;
            return null;
          },
          onRetry: (_, __) async => throw UnimplementedError(),
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
        expect(refreshCalled, isTrue);
      },
    );

    test(
      'Returns ShortResponseWithError when retryRequest fails '
      'in already-refreshed path',
      () async {
        final sut = _TestAuthInterceptor(
          onGetAuthData: () async => authData,
          onTransform: (r, _) async => r,
          onAuthError: (_) => true,
          onShouldRefresh: (_, __) => false,
          onRefresh: (_) async => throw UnimplementedError(),
          onRetry: (_, __) async => Failure(
            CancellationException(
              source: 'test',
              message: 'retry failed',
              request: RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET),
            ),
          ),
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
      },
    );

    test(
      'Returns ShortResponseWithError when retryRequest fails '
      'after refresh',
      () async {
        final sut = _TestAuthInterceptor(
          onGetAuthData: () async => authData,
          onTransform: (r, _) async => r,
          onAuthError: (_) => true,
          onShouldRefresh: (_, __) => true,
          onRefresh: (_) async => newAuthData,
          onRetry: (_, __) async => Failure(
            CancellationException(
              source: 'test',
              message: 'retry failed',
              request: RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET),
            ),
          ),
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
      },
    );
  });
}
