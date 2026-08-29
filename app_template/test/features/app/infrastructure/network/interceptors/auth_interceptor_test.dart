// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:app_template/features/app/application/use_cases/get_auth_info_use_case.dart';
import 'package:app_template/features/app/application/use_cases/get_refreshed_auth_info_use_case.dart';
import 'package:app_template/features/app/domain/models/auth_info.dart';
import 'package:app_template/features/app/infrastructure/network/interceptors/auth_interceptor.dart';
import 'package:dart_functionals/dart_functionals.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:net_client/net_client.dart';

class _MockNetClient extends Mock implements NetClient {}

class _MockGetAuthInfoUseCase extends Mock implements GetAuthInfoUseCase {}

class _MockGetRefreshedAuthInfoUseCase extends Mock
    implements GetRefreshedAuthInfoUseCase {}

void main() {
  const accessToken =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMn0.2DPnF-zMjAka6iaq_JE-Tq1ir4d-OALNh-k96HRVLiY';
  const newAccessToken =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTYxNjIzOTAyMn0.BtpKXeC14PNaSjwp-ZvgcNZYoM9cd5UZp9C_86q-MCk';
  final authInfo = AuthInfo(
    accessToken: accessToken,
    refreshToken: 'refresh',
    accessTokenExpiry: DateTime.now().add(const Duration(days: 1)),
    refreshTokenExpiry: DateTime.now().add(const Duration(days: 2)),
  );

  late _MockNetClient mockClient;
  late _MockGetAuthInfoUseCase mockGetAuthInfo;
  late _MockGetRefreshedAuthInfoUseCase mockGetRefreshedAuthInfo;

  late AuthInterceptor sut;

  setUpAll(() {
    registerFallbackValue(RequestSpec(pathOrUrl: '', method: HttpMethod.GET));
  });

  setUp(() {
    mockClient = _MockNetClient();
    mockGetAuthInfo = _MockGetAuthInfoUseCase();
    mockGetRefreshedAuthInfo = _MockGetRefreshedAuthInfoUseCase();
    sut = AuthInterceptor(
      mockClient,
      mockGetAuthInfo,
      mockGetRefreshedAuthInfo,
    );
  });

  group('transformRequestWithAuthData', () {
    test('Adds bearer token to authorization header', () async {
      final request = RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET);

      final result = await sut.transformRequestWithAuthData(request, authInfo);

      expect(
        result.headers[HttpHeaders.authorizationHeader],
        'Bearer $accessToken',
      );
    });
  });

  group('didServerReportAuthError', () {
    test('Returns true for 401 with access_token_expired', () {
      final response = RawResponse(
        statusCode: HttpStatus.unauthorized,
        rawResponseBody: {'error_id': 'access_token_expired'},
        responseHeaders: {},
        request: RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET),
      );

      expect(sut.didServerReportAuthError(response), isTrue);
    });

    test('Returns false for 401 without access_token_expired', () {
      final response = RawResponse(
        statusCode: HttpStatus.unauthorized,
        rawResponseBody: {'error_id': 'other_error'},
        responseHeaders: {},
        request: RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET),
      );

      expect(sut.didServerReportAuthError(response), isFalse);
    });

    test('Returns false for non-401 status code', () {
      final response = RawResponse(
        statusCode: HttpStatus.badRequest,
        rawResponseBody: {'error_id': 'access_token_expired'},
        responseHeaders: {},
        request: RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET),
      );

      expect(sut.didServerReportAuthError(response), isFalse);
    });
  });

  group('getAuthData', () {
    test('Delegates to GetAuthInfoUseCase', () async {
      when(() => mockGetAuthInfo()).thenAnswer((_) async => authInfo);

      final result = await sut.getAuthData();

      expect(result, same(authInfo));
    });
  });

  group('requestAuthDataRefresh', () {
    test(
      'Delegates to GetRefreshedAuthInfoUseCase and returns result',
      () async {
        when(
          () => mockGetRefreshedAuthInfo(),
        ).thenAnswer((_) async => authInfo);

        final result = await sut.requestAuthDataRefresh(authInfo);

        expect(result, same(authInfo));
      },
    );

    test('Returns null when use case returns null', () async {
      when(() => mockGetRefreshedAuthInfo()).thenAnswer((_) async => null);

      final result = await sut.requestAuthDataRefresh(authInfo);

      expect(result, isNull);
    });
  });

  group('retryRequest', () {
    test('Executes on target client', () async {
      final request = RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET);
      when(() => mockClient.execute(spec: any(named: 'spec'))).thenAnswer(
        (_) async => Success(
          NetClientResponse(
            isError: false,
            statusCode: HttpStatus.ok,
            data: null,
            headers: {},
            requestSpec: request,
          ),
        ),
      );

      final result = await sut.retryRequest(request, authInfo);

      expect(result.isSuccess, isTrue);
      verify(() => mockClient.execute(spec: request)).called(1);
    });
  });

  group('shouldRefreshAuthData', () {
    test('Returns true when request has no auth header', () {
      final request = RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET);

      expect(sut.shouldRefreshAuthData(request, authInfo), isTrue);
    });

    test('Returns true when request has the same expired token', () {
      final request = RequestSpec(
        pathOrUrl: '/test',
        method: HttpMethod.GET,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $accessToken'},
      );

      expect(sut.shouldRefreshAuthData(request, authInfo), isTrue);
    });

    test('Returns false when request already has a newer token', () {
      final request = RequestSpec(
        pathOrUrl: '/test',
        method: HttpMethod.GET,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $newAccessToken'},
      );

      expect(sut.shouldRefreshAuthData(request, authInfo), isFalse);
    });
  });
}
