// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:app_template/features/app/domain/models/auth_info.dart';
import 'package:app_template/features/app/infrastructure/network/interceptors/collaborators/app_auth_refresh_policy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:net_client/net_client.dart';

void main() {
  const expiredToken =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTUxNjIzOTAyMn0.2DPnF-zMjAka6iaq_JE-Tq1ir4d-OALNh-k96HRVLiY';
  const newerToken =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWUsImlhdCI6MTYxNjIzOTAyMn0.BtpKXeC14PNaSjwp-ZvgcNZYoM9cd5UZp9C_86q-MCk';

  const policy = AppAuthRefreshPolicy();

  RequestSpec requestWithToken(String? token) => RequestSpec(
    pathOrUrl: '/test',
    method: HttpMethod.GET,
    headers: {
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
    },
  );

  RawResponse response(int statusCode, Object? body) => RawResponse(
    statusCode: statusCode,
    rawResponseBody: body,
    responseHeaders: {},
    request: RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET),
  );

  group('didServerReportAuthError', () {
    test('Returns true for unauthorized with access_token_expired', () {
      expect(
        policy.didServerReportAuthError(
          response(HttpStatus.unauthorized, {
            'error_id': 'access_token_expired',
          }),
        ),
        isTrue,
      );
    });

    test('Returns false when status is not unauthorized', () {
      expect(
        policy.didServerReportAuthError(
          response(HttpStatus.badRequest, {'error_id': 'access_token_expired'}),
        ),
        isFalse,
      );
    });

    test('Returns false when error_id is not access_token_expired', () {
      expect(
        policy.didServerReportAuthError(
          response(HttpStatus.unauthorized, {'error_id': 'other_error'}),
        ),
        isFalse,
      );
    });

    test('Returns false when body is not a map', () {
      expect(
        policy.didServerReportAuthError(
          response(HttpStatus.unauthorized, 'not-a-map'),
        ),
        isFalse,
      );
    });
  });

  group('shouldRefreshAuthData', () {
    AuthInfo authInfo(String token) => AuthInfo(
      accessToken: token,
      refreshToken: 'refresh',
      accessTokenExpiry: DateTime.now().add(const Duration(days: 1)),
      refreshTokenExpiry: DateTime.now().add(const Duration(days: 2)),
    );

    test('Returns true when request has the same token', () {
      expect(
        policy.shouldRefreshAuthData(
          requestWithToken(expiredToken),
          authInfo(expiredToken),
        ),
        isTrue,
      );
    });

    test('Returns false when request has a newer token', () {
      expect(
        policy.shouldRefreshAuthData(
          requestWithToken(newerToken),
          authInfo(expiredToken),
        ),
        isFalse,
      );
    });

    test('Returns true when request has no authorization header', () {
      expect(
        policy.shouldRefreshAuthData(
          requestWithToken(null),
          authInfo(expiredToken),
        ),
        isTrue,
      );
    });

    test('Returns true when authorization header is not a valid token', () {
      final request = RequestSpec(
        pathOrUrl: '/test',
        method: HttpMethod.GET,
        headers: {HttpHeaders.authorizationHeader: 'not-a-jwt'},
      );

      expect(
        policy.shouldRefreshAuthData(request, authInfo(expiredToken)),
        isTrue,
      );
    });
  });
}
