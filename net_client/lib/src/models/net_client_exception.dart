import 'package:net_client/src/clients/net_client.dart';
import 'package:net_client/src/contracts/mappable.dart';
import 'package:net_client/src/enums/transport_exception_type.dart';
import 'package:net_client/src/models/request_spec.dart';

/// The base exception returned by [NetClient] when it encounters any error.
///
/// See its subtypes for more details.
sealed class NetClientException implements Mappable {
  /// The original request.
  final RequestSpec request;

  /// The underlying cause of this exception.
  ///
  /// **Warning**:
  /// This value can be transport or runtime specific, and may come
  /// from the underlying HTTP client. This is not a part of the stable
  /// API and should never be used for control flow.
  final Object? cause;

  /// Stack trace associated with this failure.
  ///
  /// **Warning**:
  /// This value can be transport or runtime specific, and may come
  /// from the underlying HTTP client. This is not a part of the stable
  /// API and should never be used for control flow.
  final StackTrace? stackTrace;

  const NetClientException({
    required this.request,
    this.cause,
    this.stackTrace,
  });
}

/// A network failure.
final class TransportException extends NetClientException {
  /// The type of network failure.
  final TransportExceptionType type;

  const TransportException({
    required this.type,
    required super.request,
    super.cause,
    super.stackTrace,
  });

  TransportException copyWith({
    TransportExceptionType? type,
    RequestSpec? request,
    Object? cause,
    StackTrace? stackTrace,
  }) {
    return TransportException(
      type: type ?? this.type,
      request: request ?? this.request,
      cause: cause ?? this.cause,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }

  @override
  String toString() {
    return 'TransportException {request: $request, type: $type}';
  }

  @override
  Map<String, dynamic> toMap() {
    return {'type': type, 'request': request.toMap()};
  }
}

/// A failure indicating explicit request cancellation.
final class CancellationException extends NetClientException {
  /// An identifier of the cancellation source.
  final String source;

  /// An message to clarify the reason of the cancellation.
  final String message;

  const CancellationException({
    required this.source,
    required this.message,
    required super.request,
    super.cause,
    super.stackTrace,
  });

  CancellationException copyWith({
    String? source,
    String? message,
    RequestSpec? request,
    Object? cause,
    StackTrace? stackTrace,
  }) {
    return CancellationException(
      source: source ?? this.source,
      message: message ?? this.message,
      request: request ?? this.request,
      cause: cause ?? this.cause,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }

  @override
  String toString() {
    return 'CancellationException {request: $request, source: $source}';
  }

  @override
  Map<String, dynamic> toMap() {
    return {'source': source, 'request': request.toMap()};
  }
}

/// Generic failure indicating an unexpected exception from the client.
final class UnexpectedException extends NetClientException {
  /// Summary of the unexpected failure.
  ///
  /// This should not be used for control flow.
  final String message;

  const UnexpectedException({
    required this.message,
    required super.request,
    super.cause,
    super.stackTrace,
  });

  UnexpectedException copyWith({
    String? message,
    RequestSpec? request,
    Object? cause,
    StackTrace? stackTrace,
  }) {
    return UnexpectedException(
      message: message ?? this.message,
      request: request ?? this.request,
      cause: cause ?? this.cause,
      stackTrace: stackTrace ?? this.stackTrace,
    );
  }

  @override
  String toString() {
    return 'UnexpectedException {request: $request, message: $message}';
  }

  @override
  Map<String, dynamic> toMap() {
    return {'message': message, 'request': request.toMap()};
  }
}
