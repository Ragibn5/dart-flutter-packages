// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:app_template/features/app/application/use_cases/get_auth_info_use_case.dart';
import 'package:app_template/features/app/application/use_cases/get_refreshed_auth_info_use_case.dart';
import 'package:app_template/features/app/domain/models/auth_info.dart';
import 'package:app_template/features/app/infrastructure/network/interceptors/auth_interceptor.dart';
import 'package:app_template/features/app/infrastructure/network/interceptors/collaborators/app_auth_data_provider.dart';
import 'package:app_template/features/app/infrastructure/network/interceptors/collaborators/app_auth_refresh_policy.dart';
import 'package:app_template/features/app/infrastructure/network/interceptors/collaborators/app_auth_request_transformer.dart';
import 'package:app_template/features/app/infrastructure/network/interceptors/collaborators/app_request_retrier.dart';
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
  final newAuthInfo = AuthInfo(
    accessToken: newAccessToken,
    refreshToken: 'new-refresh',
    accessTokenExpiry: DateTime.now().add(const Duration(days: 1)),
    refreshTokenExpiry: DateTime.now().add(const Duration(days: 2)),
  );

  late _MockNetClient mockClient;
  late _MockGetAuthInfoUseCase mockGetAuthInfo;
  late _MockGetRefreshedAuthInfoUseCase mockGetRefreshedAuthInfo;

  late AuthInterceptor sut;

  setUpAll(() {
    registerFallbackValue(RequestSpec(pathOrUrl: '', method: HttpMethod.GET));
    registerFallbackValue(
      RawResponse(
        statusCode: HttpStatus.ok,
        rawResponseBody: null,
        responseHeaders: {},
        request: RequestSpec(pathOrUrl: '', method: HttpMethod.GET),
      ),
    );
  });

  setUp(() {
    mockClient = _MockNetClient();
    mockGetAuthInfo = _MockGetAuthInfoUseCase();
    mockGetRefreshedAuthInfo = _MockGetRefreshedAuthInfoUseCase();
    sut = AuthInterceptor(
      AppAuthDataProvider(mockGetAuthInfo, mockGetRefreshedAuthInfo),
      const AppAuthRefreshPolicy(),
      const AppAuthRequestTransformer(),
      AppRequestRetrier(mockClient),
    );
    when(() => mockClient.execute(spec: any(named: 'spec'))).thenAnswer(
      (invocation) async => Success(
        NetClientResponse(
          isError: false,
          statusCode: HttpStatus.ok,
          data: null,
          headers: {},
          requestSpec: invocation.namedArguments[#spec] as RequestSpec,
        ),
      ),
    );
  });

  group('onRequest', () {
    test('Adds bearer token to authorization header', () async {
      when(() => mockGetAuthInfo()).thenAnswer((_) async => authInfo);

      final request = RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET);
      final result = await sut.onRequest(request);

      expect(result, isA<ContinueWithRequest>());
      expect(
        (result as ContinueWithRequest).request.headers[HttpHeaders
            .authorizationHeader],
        'Bearer $accessToken',
      );
    });

    test(
      'Returns ShortRequestWithError when getAuthInfo returns null',
      () async {
        when(() => mockGetAuthInfo()).thenAnswer((_) async => null);

        final request = RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET);
        final result = await sut.onRequest(request);

        expect(result, isA<ShortRequestWithError>());
      },
    );
  });

  group('onResponse', () {
    RawResponse unauthorizedResponse(RequestSpec request) => RawResponse(
      statusCode: HttpStatus.unauthorized,
      rawResponseBody: {'error_id': 'access_token_expired'},
      responseHeaders: {},
      request: request,
    );

    test('Passes through when status is not unauthorized', () async {
      final response = RawResponse(
        statusCode: HttpStatus.badRequest,
        rawResponseBody: {'error_id': 'access_token_expired'},
        responseHeaders: {},
        request: RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET),
      );

      final result = await sut.onResponse(response);

      expect(result, isA<ContinueWithResponse>());
      verifyNever(() => mockClient.execute(spec: any(named: 'spec')));
    });

    test('Passes through when error_id is not access_token_expired', () async {
      final response = RawResponse(
        statusCode: HttpStatus.unauthorized,
        rawResponseBody: {'error_id': 'other_error'},
        responseHeaders: {},
        request: RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET),
      );

      final result = await sut.onResponse(response);

      expect(result, isA<ContinueWithResponse>());
      verifyNever(() => mockClient.execute(spec: any(named: 'spec')));
    });

    test(
      'Retries without refresh when request already has a newer token',
      () async {
        when(() => mockGetAuthInfo()).thenAnswer((_) async => authInfo);

        final request = RequestSpec(
          pathOrUrl: '/test',
          method: HttpMethod.GET,
          headers: {HttpHeaders.authorizationHeader: 'Bearer $newAccessToken'},
        );
        final result = await sut.onResponse(unauthorizedResponse(request));

        expect(result, isA<ShortResponseWithFinalResponse>());
        verify(() => mockClient.execute(spec: request)).called(1);
        verifyNever(() => mockGetRefreshedAuthInfo());
      },
    );

    test(
      'Refreshes then retries when request uses the expired token',
      () async {
        when(() => mockGetAuthInfo()).thenAnswer((_) async => authInfo);
        when(
          () => mockGetRefreshedAuthInfo(),
        ).thenAnswer((_) async => newAuthInfo);

        final request = RequestSpec(
          pathOrUrl: '/test',
          method: HttpMethod.GET,
          headers: {HttpHeaders.authorizationHeader: 'Bearer $accessToken'},
        );
        final result = await sut.onResponse(unauthorizedResponse(request));

        expect(result, isA<ShortResponseWithFinalResponse>());
        verify(() => mockGetRefreshedAuthInfo()).called(1);
        verify(() => mockClient.execute(spec: request)).called(1);
      },
    );

    test('Returns an error when auth data is unavailable', () async {
      when(() => mockGetAuthInfo()).thenAnswer((_) async => null);

      final response = unauthorizedResponse(
        RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET),
      );
      final result = await sut.onResponse(response);

      expect(result, isA<ShortResponseWithError>());
      verifyNever(() => mockClient.execute(spec: any(named: 'spec')));
      verifyNever(() => mockGetRefreshedAuthInfo());
    });
  });
}
