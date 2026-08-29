// ignore_for_file: avoid_init_to_null

import 'package:net_client/src/contracts/mappable.dart';
import 'package:net_client/src/enums/http_method.dart';
import 'package:net_client/src/models/request_body.dart';

class RequestSpec implements Mappable {
  /// The endpoint path, relative to the base URL.
  final String pathOrUrl;

  /// The HTTP method to use for this request.
  final HttpMethod method;

  /// Request specific query params.
  final Map<String, dynamic> queryParameters;

  /// Request specific headers.
  final Map<String, dynamic> headers;

  /// The request body to send.
  ///
  /// NOTE: Pass `null` for requests with no body.
  final RequestBody? body;

  /// The base URL.
  final String? baseUrl;

  /// Timeout for sending the request.
  final Duration? sendTimeout;

  /// Timeout for receiving the request.
  final Duration? receiveTimeout;

  /// Timeout for the connection.
  final Duration? connectionTimeout;

  /// Whether to follow redirects.
  final bool? followRedirects;

  /// Maximum number of redirects to follow.
  final int? maxRedirects;

  RequestSpec({
    required this.pathOrUrl,
    required this.method,
    Map<String, dynamic> queryParameters = const {},
    Map<String, dynamic> headers = const {},
    this.body,
    this.baseUrl,
    this.sendTimeout,
    this.receiveTimeout,
    this.connectionTimeout,
    this.followRedirects,
    this.maxRedirects,
  })  : queryParameters = Map.of(queryParameters),
        headers = Map.of(headers);

  /// A uri constructed by combining [baseUrl], [pathOrUrl],
  /// and [queryParameters].
  ///
  /// **Note:**
  /// The actual api call execution may not use this to deduce the url it hits.
  /// So, use it for logging, debugging, and display purposes, but not for app
  /// flow, or anything important.
  Uri get uri {
    final base = baseUrl;
    final qp = queryParameters;

    Map<String, String>? resolvedQp;
    if (qp.isNotEmpty) {
      resolvedQp = qp.map((k, v) => MapEntry(k, '$v'));
    }

    if (base == null) {
      return Uri.parse(pathOrUrl).replace(queryParameters: resolvedQp);
    }

    final parsed = Uri.parse(pathOrUrl);
    if (parsed.hasScheme) {
      return parsed.replace(queryParameters: resolvedQp);
    }

    final prefix = base.endsWith('/') ? base : '$base/';
    final path = pathOrUrl.startsWith('/') ? pathOrUrl.substring(1) : pathOrUrl;
    return Uri.parse('$prefix$path')
        .replace(queryParameters: resolvedQp)
        .normalizePath();
  }

  RequestSpec copyWith({
    String? pathOrUrl,
    HttpMethod? method,
    RequestBody? body,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    String? baseUrl,
    Duration? sendTimeout,
    Duration? receiveTimeout,
    Duration? connectionTimeout,
    bool? followRedirects,
    int? maxRedirects,
  }) {
    return RequestSpec(
      pathOrUrl: pathOrUrl ?? this.pathOrUrl,
      method: method ?? this.method,
      body: body ?? this.body,
      queryParameters: queryParameters ?? this.queryParameters,
      headers: headers ?? this.headers,
      baseUrl: baseUrl ?? this.baseUrl,
      sendTimeout: sendTimeout ?? this.sendTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      connectionTimeout: connectionTimeout ?? this.connectionTimeout,
      followRedirects: followRedirects ?? this.followRedirects,
      maxRedirects: maxRedirects ?? this.maxRedirects,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'pathOrUrl': pathOrUrl,
      'method': method,
      'body': body?.toMap(),
      'queryParameters': queryParameters,
      'headers': headers,
      'baseUrl': baseUrl,
      'sendTimeout': sendTimeout,
      'receiveTimeout': receiveTimeout,
      'connectionTimeout': connectionTimeout,
      'followRedirects': followRedirects,
      'maxRedirects': maxRedirects,
    };
  }
}
