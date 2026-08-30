// ignore_for_file: lines_longer_than_80_chars, avoid_redundant_argument_values, cascade_invocations

import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:net_client/src/clients/dio/dio_exception_mapper.dart';
import 'package:net_client/src/enums/http_method.dart';
import 'package:net_client/src/enums/transport_exception_type.dart';
import 'package:net_client/src/models/net_client_exception.dart';
import 'package:net_client/src/models/request_spec.dart';
import 'package:test/test.dart';

class _MockRequestOptions extends Mock implements RequestOptions {}

void main() {
  late _MockRequestOptions mockRequestOptions;

  late DioExceptionMapper sut;

  final requestSpec = RequestSpec(
    pathOrUrl: '/test',
    method: HttpMethod.GET,
  );

  void verifyTransportExceptionPath({
    required DioException exception,
    required RequestSpec request,
    Object? expectedInnerCause,
    StackTrace? expectedStackTrace,
    required TransportExceptionType expectedType,
  }) {
    final result = sut.mapException(
      request: request,
      exception: exception,
      stackTrace: expectedStackTrace,
    );

    expect(
      result,
      isA<TransportException>()
          .having((p) => p.type, 'type', expectedType)
          .having((p) => p.request, 'request', request)
          .having((p) => p.cause, 'cause', expectedInnerCause)
          .having((p) => p.stackTrace, 'stackTrace', expectedStackTrace),
    );
  }

  void validateUnexpectedExceptionPath(DioExceptionType type) {
    final st = StackTrace.current;
    final innerCause = Exception();
    final dioException = DioException(
      requestOptions: mockRequestOptions,
      response: null,
      type: type,
      error: innerCause,
      stackTrace: st,
    );

    final result = sut.mapException(
      request: requestSpec,
      exception: dioException,
      stackTrace: st,
    );

    expect(
      result,
      isA<UnexpectedException>()
          .having((p) => p.request, 'request', requestSpec)
          .having(
            (p) => p.message,
            'message',
            'Client threw unknown exception (${dioException.type.name}): ${dioException.message}',
          )
          .having((p) => p.cause, 'cause', innerCause)
          .having((p) => p.stackTrace, 'stackTrace', st),
    );
  }

  setUp(() {
    mockRequestOptions = _MockRequestOptions();

    sut = const DioExceptionMapper();

    when(() => mockRequestOptions.preserveHeaderCase).thenReturn(true);
  });

  test(
    'Non-$DioException maps to UnexpectedException',
    () {
      final st = StackTrace.current;
      final cause = Exception('invalid-exception');

      final result = sut.mapException(
        request: requestSpec,
        exception: cause,
        stackTrace: st,
      );

      expect(
        result,
        isA<UnexpectedException>()
            .having((p) => p.request, 'request', requestSpec)
            .having((p) => p.message, 'message', 'Received unknown exception')
            .having((p) => p.cause, 'cause', cause)
            .having((p) => p.stackTrace, 'stackTrace', st),
      );
    },
  );

  test(
    '$DioException error types map to TransportException',
    () {
      final st = StackTrace.current;
      final innerCause = Exception();
      final matchingDioToNetworkExceptionTypes = [
        (
          DioExceptionType.connectionTimeout,
          TransportExceptionType.CONNECTION_TIMEOUT
        ),
        (DioExceptionType.sendTimeout, TransportExceptionType.SEND_TIMEOUT),
        (
          DioExceptionType.receiveTimeout,
          TransportExceptionType.RECEIVE_TIMEOUT
        ),
        (
          DioExceptionType.badCertificate,
          TransportExceptionType.BAD_CERTIFICATE
        ),
        (
          DioExceptionType.connectionError,
          TransportExceptionType.CONNECTION_ERROR
        ),
      ];
      for (final type in matchingDioToNetworkExceptionTypes) {
        final dioException = DioException(
          requestOptions: mockRequestOptions,
          type: type.$1,
          error: innerCause,
          stackTrace: st,
        );

        verifyTransportExceptionPath(
          exception: dioException,
          request: requestSpec,
          expectedInnerCause: innerCause,
          expectedStackTrace: st,
          expectedType: type.$2,
        );
      }
    },
  );

  test(
    '${DioExceptionType.cancel} maps to CancellationException',
    () {
      final st = StackTrace.current;
      final innerCause = Exception();
      final dioException = DioException(
        requestOptions: mockRequestOptions,
        type: DioExceptionType.cancel,
        error: innerCause,
        stackTrace: st,
      );

      final result = sut.mapException(
        request: requestSpec,
        exception: dioException,
        stackTrace: st,
      );

      expect(
        result,
        isA<CancellationException>()
            .having((p) => p.source, 'source', 'client_exception_mapper')
            .having((p) => p.request, 'request', requestSpec)
            .having((p) => p.cause, 'cause', innerCause)
            .having((p) => p.stackTrace, 'stackTrace', st),
      );
    },
  );

  test(
    '${DioExceptionType.unknown} maps to UnexpectedException',
    () {
      const msg = 'exp-msg';
      final st = StackTrace.current;
      final innerCause = Exception();
      final dioException = DioException(
        requestOptions: mockRequestOptions,
        type: DioExceptionType.unknown,
        error: innerCause,
        stackTrace: st,
        message: msg,
      );

      final result = sut.mapException(
        request: requestSpec,
        exception: dioException,
        stackTrace: st,
      );

      expect(
        result,
        isA<UnexpectedException>()
            .having((p) => p.request, 'request', requestSpec)
            .having(
              (p) => p.message,
              'message',
              'Client threw unknown exception (${DioExceptionType.unknown.name}): $msg',
            )
            .having((p) => p.cause, 'cause', innerCause)
            .having((p) => p.stackTrace, 'stackTrace', st),
      );
    },
  );

  test(
    '${DioExceptionType.unknown} and ${DioExceptionType.badResponse} map to UnexpectedException',
    () {
      final types = [DioExceptionType.unknown, DioExceptionType.badResponse];
      types.forEach(validateUnexpectedExceptionPath);
    },
  );
}
