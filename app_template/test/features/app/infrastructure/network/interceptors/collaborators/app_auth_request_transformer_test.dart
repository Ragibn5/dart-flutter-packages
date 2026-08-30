// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:app_template/features/app/domain/models/auth_info.dart';
import 'package:app_template/features/app/infrastructure/network/interceptors/collaborators/app_auth_request_transformer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:net_client/net_client.dart';

void main() {
  const accessToken = 'access-token';
  final authInfo = AuthInfo(
    accessToken: accessToken,
    refreshToken: 'refresh',
    accessTokenExpiry: DateTime.now().add(const Duration(days: 1)),
    refreshTokenExpiry: DateTime.now().add(const Duration(days: 2)),
  );

  const transformer = AppAuthRequestTransformer();

  test('Adds bearer token to authorization header', () async {
    final request = RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET);

    final result = await transformer.transformRequestWithAuthData(
      request,
      authInfo,
    );

    expect(
      result.headers[HttpHeaders.authorizationHeader],
      'Bearer $accessToken',
    );
  });

  test('Preserves existing headers', () async {
    final request = RequestSpec(
      pathOrUrl: '/test',
      method: HttpMethod.GET,
      headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    );

    final result = await transformer.transformRequestWithAuthData(
      request,
      authInfo,
    );

    expect(result.headers[HttpHeaders.contentTypeHeader], 'application/json');
    expect(
      result.headers[HttpHeaders.authorizationHeader],
      'Bearer $accessToken',
    );
  });

  test('Overrides existing authorization header', () async {
    final request = RequestSpec(
      pathOrUrl: '/test',
      method: HttpMethod.GET,
      headers: {HttpHeaders.authorizationHeader: 'Bearer old-token'},
    );

    final result = await transformer.transformRequestWithAuthData(
      request,
      authInfo,
    );

    expect(
      result.headers[HttpHeaders.authorizationHeader],
      'Bearer $accessToken',
    );
  });
}
