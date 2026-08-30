import 'package:net_client/src/contracts/mappable.dart';
import 'package:net_client/src/models/request_spec.dart';

class NetClientResponse implements Mappable {
  /// Whether the response is an error.
  ///
  /// This is decided by the response classifier.
  final bool isError;

  /// The status code from the server side.
  final int statusCode;

  /// The response or error body.
  final Object? data;

  /// The response headers.
  final Map<String, List<String>> headers;

  /// The request spec that was sent to the server.
  final RequestSpec requestSpec;

  const NetClientResponse({
    required this.isError,
    required this.statusCode,
    required this.data,
    required this.headers,
    required this.requestSpec,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'isError': isError,
      'statusCode': statusCode,
      'data': data,
      'headers': headers,
      'requestSpec': requestSpec.toMap(),
    };
  }
}
