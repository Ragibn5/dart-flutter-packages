import 'package:net_client/net_client.dart';

/// An interface to compose a [RequestSpec] with the given client specific
/// [ClientConfig].
abstract interface class RequestComposer {
  /// Builds a merged a [RequestSpec] from the given [RequestSpec] and
  /// [ClientConfig].
  ///
  /// Note:
  /// - Values from [source] receives precedence over the [clientConfig].
  /// - For collection type fields, such as headers and query params,
  ///   the resulting value is the result of merging all the map entries,
  ///   where values from [source] receive precedence over [clientConfig].
  RequestSpec compose(RequestSpec source, ClientConfig clientConfig);
}

class DefaultRequestComposer implements RequestComposer {
  const DefaultRequestComposer();

  @override
  RequestSpec compose(RequestSpec source, ClientConfig clientConfig) {
    return source.copyWith(
      sendTimeout: source.sendTimeout ?? clientConfig.sendTimeout,
      receiveTimeout: source.receiveTimeout ?? clientConfig.receiveTimeout,
      connectionTimeout:
          source.connectionTimeout ?? clientConfig.connectionTimeout,
      queryParameters: _mergeMaps(
        clientConfig.queryParameters,
        source.queryParameters,
      ),
      headers: _mergeMaps(
        clientConfig.headers,
        source.headers,
      ),
      baseUrl: source.baseUrl ?? clientConfig.baseUrl,
      followRedirects: source.followRedirects ?? clientConfig.followRedirects,
      maxRedirects: source.maxRedirects ?? clientConfig.maxRedirects,
    );
  }

  Map<String, dynamic>? _mergeMaps(
    Map<String, dynamic>? base,
    Map<String, dynamic>? override,
  ) {
    if (base == null && override == null) return null;
    return {
      ...?base,
      ...?override,
    };
  }
}
