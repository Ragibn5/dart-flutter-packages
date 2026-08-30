// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:app_logger/app_logger.dart';
import 'package:app_template/features/app/infrastructure/network/interceptors/logger_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:net_client/net_client.dart';

class _MockAppLogger extends Mock implements AppLogger {}

void main() {
  final requestSpec = RequestSpec(
    pathOrUrl: '/ping',
    baseUrl: 'https://abc.com',
    method: HttpMethod.GET,
    body: const JsonBody({'1': 1, 's': 'a-string'}),
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    queryParameters: {'1': 1},
  );
  final rawResponse = RawResponse(
    statusCode: HttpStatus.ok,
    rawResponseBody: {'i': 100, 's': 'another-string'},
    responseHeaders: {
      HttpHeaders.contentTypeHeader: ['application/json'],
    },
    request: requestSpec,
  );
  final exception = TransportException(
    type: TransportExceptionType.CONNECTION_ERROR,
    request: requestSpec,
  );

  late _MockAppLogger mockAppLogger;
  late LoggerInterceptor loggerInterceptor;

  setUp(() {
    mockAppLogger = _MockAppLogger();

    loggerInterceptor = LoggerInterceptor(mockAppLogger);

    when(
      () => mockAppLogger.logDebug(
        tag: any(named: 'tag'),
        message: any(named: 'message'),
        extras: any(named: 'extras'),
      ),
    ).thenAnswer((_) => {});
    when(
      () => mockAppLogger.logInfo(
        tag: any(named: 'tag'),
        message: any(named: 'message'),
        extras: any(named: 'extras'),
      ),
    ).thenAnswer((_) => {});
    when(
      () => mockAppLogger.logWarning(
        tag: any(named: 'tag'),
        message: any(named: 'message'),
        extras: any(named: 'extras'),
      ),
    ).thenAnswer((_) => {});
    when(
      () => mockAppLogger.logError(
        tag: any(named: 'tag'),
        message: any(named: 'message'),
        extras: any(named: 'extras'),
      ),
    ).thenAnswer((_) => {});
  });

  test(
    'Should log on request and propagate the request to next interceptor',
    () async {
      final result = await loggerInterceptor.onRequest(requestSpec);

      expect(result, isA<ContinueWithRequest>());

      verify(
        () => mockAppLogger.logInfo(
          tag: LoggerInterceptor.TAG,
          message: any(named: 'message'),
          extras: any(named: 'extras'),
        ),
      );
    },
  );

  test(
    'Should log on response and propagate the response to next interceptor',
    () async {
      final result = await loggerInterceptor.onResponse(rawResponse);

      expect(result, isA<ContinueWithResponse>());

      verify(
        () => mockAppLogger.logInfo(
          tag: LoggerInterceptor.TAG,
          message: any(named: 'message'),
          extras: any(named: 'extras'),
        ),
      );
    },
  );

  test(
    'Should log on error and propagate the error to next interceptor',
    () async {
      final result = await loggerInterceptor.onError(exception);

      expect(result, isA<ContinueWithError>());

      verify(
        () => mockAppLogger.logError(
          tag: LoggerInterceptor.TAG,
          message: any(named: 'message'),
          stackTrace: any(named: 'stackTrace'),
          extras: any(named: 'extras'),
        ),
      );
    },
  );
}
