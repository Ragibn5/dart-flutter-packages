// ignore_for_file: lines_longer_than_80_chars

import 'package:app_template/features/auth/data/models/auth_data_dto.dart';
import 'package:app_template/features/auth/data/models/token_refresh_request.dart';
import 'package:app_template/features/auth/infrastructure/network/clients/app_server_token_refresh_api_client_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:net_client/net_client.dart';
import 'package:net_models/net_models.dart';
import 'package:shared_models/shared_models.dart';

class _MockNetClient extends Mock implements NetClient {}

void main() {
  const path = AppServerTokenRefreshApiClientImpl.path;
  const tokenRefreshRequest = TokenRefreshRequest(refreshToken: 'refreshToken');

  final now = DateTime.now().toUtc();
  final sampleAuthData = AuthDataDTO(
    userId: 'userId',
    accessToken: 'new_access_token',
    refreshToken: 'new_refresh_token',
    accessTokenExpiry: now.add(const Duration(days: 1)),
    refreshTokenExpiry: now.add(const Duration(days: 2)),
  );
  const sampleServerMessage = ServerMessage(code: 'error', message: 'Error');

  late AppServerTokenRefreshApiClientImpl sut;

  setUp(() {
    sut = AppServerTokenRefreshApiClientImpl(_MockNetClient());
  });

  test('createRequest returns request model with proper values', () {
    final result = sut.createRequest(tokenRefreshRequest);

    expect(result.pathOrUrl, path);
    expect(result.method, HttpMethod.GET);
    expect(result.body, isA<JsonBody>());
    final body = result.body! as JsonBody;
    expect(body.data, tokenRefreshRequest.toJson());
  });

  test('decodeResponse returns AuthDataDTO from non-error response', () {
    final response = NetClientResponse(
      isError: false,
      statusCode: 200,
      data: sampleAuthData.toJson(),
      headers: {},
      requestSpec: RequestSpec(pathOrUrl: '', method: HttpMethod.GET),
    );

    final result = sut.decodeResponse(response);

    expect(result, isA<SuccessResponse<AuthDataDTO>>());
    expect((result as SuccessResponse).data, sampleAuthData);
  });

  test('decodeResponse returns Failure from error response', () {
    final response = NetClientResponse(
      isError: true,
      statusCode: 400,
      data: sampleServerMessage.toJson(),
      headers: {},
      requestSpec: RequestSpec(pathOrUrl: '', method: HttpMethod.GET),
    );

    final result = sut.decodeResponse(response);

    expect(result, isA<FailureResponse<ServerMessage>>());
    expect((result as FailureResponse).error, sampleServerMessage);
  });
}
