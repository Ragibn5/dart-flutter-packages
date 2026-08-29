import 'package:dio/dio.dart';
import 'package:net_client/net_client.dart';

class DioExceptionMapper {
  const DioExceptionMapper();

  NetClientException mapException({
    required RequestSpec request,
    required Object exception,
    StackTrace? stackTrace,
  }) {
    if (exception is! DioException) {
      return UnexpectedException(
        message: 'Received unknown exception',
        request: request,
        cause: exception,
        stackTrace: stackTrace,
      );
    }

    return switch (exception.type) {
      DioExceptionType.connectionTimeout => TransportException(
          type: TransportExceptionType.CONNECTION_TIMEOUT,
          request: request,
          cause: exception.error,
          stackTrace: exception.stackTrace,
        ),
      DioExceptionType.sendTimeout => TransportException(
          type: TransportExceptionType.SEND_TIMEOUT,
          request: request,
          cause: exception.error,
          stackTrace: exception.stackTrace,
        ),
      DioExceptionType.receiveTimeout => TransportException(
          type: TransportExceptionType.RECEIVE_TIMEOUT,
          request: request,
          cause: exception.error,
          stackTrace: exception.stackTrace,
        ),
      DioExceptionType.badCertificate => TransportException(
          type: TransportExceptionType.BAD_CERTIFICATE,
          request: request,
          cause: exception.error,
          stackTrace: exception.stackTrace,
        ),
      DioExceptionType.connectionError => TransportException(
          type: TransportExceptionType.CONNECTION_ERROR,
          request: request,
          cause: exception.error,
          stackTrace: exception.stackTrace,
        ),
      DioExceptionType.cancel => CancellationException(
          source: 'client_exception_mapper',
          message: 'Cancelling on request from the underlying client',
          request: request,
          cause: exception.error,
          stackTrace: exception.stackTrace,
        ),
      _ => UnexpectedException(
          message:
              // ignore: lines_longer_than_80_chars
              'Client threw unknown exception (${exception.type.name}): ${exception.message}',
          request: request,
          cause: exception.error,
          stackTrace: exception.stackTrace,
        ),
    };
  }
}
