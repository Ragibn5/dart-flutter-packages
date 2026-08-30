// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:app_template/features/app/domain/models/auth_info.dart';
import 'package:app_template/features/app/infrastructure/network/interceptors/collaborators/app_request_retrier.dart';
import 'package:dart_functionals/dart_functionals.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:net_client/net_client.dart';

class _MockNetClient extends Mock implements NetClient {}

void main() {
  final authInfo = AuthInfo(
    accessToken: 'access',
    refreshToken: 'refresh',
    accessTokenExpiry: DateTime.now().add(const Duration(days: 1)),
    refreshTokenExpiry: DateTime.now().add(const Duration(days: 2)),
  );

  late _MockNetClient mockClient;
  late AppRequestRetrier sut;

  setUpAll(() {
    registerFallbackValue(RequestSpec(pathOrUrl: '', method: HttpMethod.GET));
  });

  setUp(() {
    mockClient = _MockNetClient();
    sut = AppRequestRetrier(mockClient);
  });

  ApiCallResult resultFor(RequestSpec request) => Success<NetClientResponse>(
    NetClientResponse(
      isError: false,
      statusCode: HttpStatus.ok,
      data: null,
      headers: {},
      requestSpec: request,
    ),
  );

  test('Delegates the request to the target client', () async {
    final request = RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET);
    when(() => mockClient.execute(spec: any(named: 'spec'))).thenAnswer(
      (invocation) async =>
          resultFor(invocation.namedArguments[#spec] as RequestSpec),
    );

    final result = await sut.retryRequest(request, authInfo);

    expect(result, isA<Success<NetClientResponse>>());
    verify(() => mockClient.execute(spec: request)).called(1);
  });

  test('Propagates a failure result from the target client', () async {
    final request = RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET);
    when(() => mockClient.execute(spec: any(named: 'spec'))).thenAnswer(
      (_) async => Failure<NetClientException>(
        CancellationException(
          source: 'test',
          message: 'failed',
          request: request,
        ),
      ),
    );

    final result = await sut.retryRequest(request, authInfo);

    expect(result, isA<Failure<NetClientException>>());
    verify(() => mockClient.execute(spec: request)).called(1);
  });
}
