import 'package:feature_api_client/feature_api_client.dart';
import 'package:net_client/net_client.dart';
import 'package:net_models/net_models.dart';
import 'package:test/test.dart';

void main() {
  const transformer = NetClientExceptionTransformer();

  final request = RequestSpec(pathOrUrl: '/test', method: HttpMethod.GET);

  test('Should map TransportException to TransportError', () {
    for (final type in TransportExceptionType.values) {
      final exception = TransportException(type: type, request: request);
      final result = transformer.transformApiError(exception);

      expect(result, isA<TransportError>());
      expect((result as TransportError).type.name, type.name);
    }
  });

  test('Should map CancellationException to CancellationError', () {
    final exception = CancellationException(
      source: 'user',
      message: 'cancelled',
      request: request,
    );
    final result = transformer.transformApiError(exception);

    expect(result, isA<CancellationError>());
    expect((result as CancellationError).source, 'user');
  });

  test('Should map UnexpectedException to UnexpectedError with cause', () {
    final cause = Exception('boom');
    final exception = UnexpectedException(
      message: 'unexpected',
      request: request,
      cause: cause,
      stackTrace: StackTrace.current,
    );
    final result = transformer.transformApiError(exception);

    expect(result, isA<UnexpectedError>());
    expect((result as UnexpectedError).cause, cause);
  });

  test('Should map TransportExceptionType correctly', () {
    final mappings = {
      TransportExceptionType.CONNECTION_TIMEOUT:
          TransportErrorType.CONNECTION_TIMEOUT,
      TransportExceptionType.SEND_TIMEOUT: TransportErrorType.SEND_TIMEOUT,
      TransportExceptionType.RECEIVE_TIMEOUT:
          TransportErrorType.RECEIVE_TIMEOUT,
      TransportExceptionType.CONNECTION_ERROR:
          TransportErrorType.CONNECTION_ERROR,
      TransportExceptionType.BAD_CERTIFICATE:
          TransportErrorType.BAD_CERTIFICATE,
    };

    for (final entry in mappings.entries) {
      final exception = TransportException(
        type: entry.key,
        request: request,
      );
      final result = transformer.transformApiError(exception);
      expect((result as TransportError).type, entry.value);
    }
  });
}
