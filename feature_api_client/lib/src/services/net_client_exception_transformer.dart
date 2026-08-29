import 'package:net_client/net_client.dart';
import 'package:net_models/net_models.dart';

class NetClientExceptionTransformer {
  const NetClientExceptionTransformer();

  ApiError transformApiError(NetClientException e) {
    final ApiError result;
    if (e is TransportException) {
      result = TransportError(
        type: _toAppTransportErrorType(e.type),
      );
    } else if (e is CancellationException) {
      result = CancellationError(source: e.source);
    } else if (e is UnexpectedException) {
      result = UnexpectedError(
        cause: e.cause,
        stackTrace: e.stackTrace,
      );
    } else {
      result = UnexpectedError(cause: e, stackTrace: StackTrace.current);
    }

    return result;
  }

  TransportErrorType _toAppTransportErrorType(
    TransportExceptionType netKitTransportErrorType,
  ) {
    return switch (netKitTransportErrorType) {
      TransportExceptionType.CONNECTION_TIMEOUT =>
        TransportErrorType.CONNECTION_TIMEOUT,
      TransportExceptionType.SEND_TIMEOUT => TransportErrorType.SEND_TIMEOUT,
      TransportExceptionType.RECEIVE_TIMEOUT =>
        TransportErrorType.RECEIVE_TIMEOUT,
      TransportExceptionType.CONNECTION_ERROR =>
        TransportErrorType.CONNECTION_ERROR,
      TransportExceptionType.BAD_CERTIFICATE =>
        TransportErrorType.BAD_CERTIFICATE,
    };
  }
}
