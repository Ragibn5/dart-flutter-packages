import 'package:net_client/src/contracts/mappable.dart';
import 'package:net_client/src/models/request_spec.dart';

class RawResponse implements Mappable {
  /// The status code from the server side.
  final int statusCode;

  /// The raw response body before decoding.
  final Object? rawResponseBody;

  /// The response headers.
  final Map<String, List<String>> responseHeaders;

  /// The original request.
  final RequestSpec request;

  const RawResponse({
    required this.statusCode,
    required this.rawResponseBody,
    required this.responseHeaders,
    required this.request,
  });

  RawResponse copyWith({
    int? statusCode,
    Object? rawResponseBody,
    Map<String, List<String>>? responseHeaders,
    RequestSpec? request,
  }) {
    return RawResponse(
      statusCode: statusCode ?? this.statusCode,
      rawResponseBody: rawResponseBody ?? this.rawResponseBody,
      responseHeaders: responseHeaders ?? this.responseHeaders,
      request: request ?? this.request,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'statusCode': statusCode,
      'rawResponseBody': rawResponseBody,
      'responseHeaders': responseHeaders,
      'request': request.toMap(),
    };
  }
}
