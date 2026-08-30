import 'package:net_client/net_client.dart';

/// Re-executes requests with auth data on behalf of the interceptor.
abstract interface class RequestRetrier<AuthData> {
  /// Re-executes [request] with the (possibly refreshed) auth data.
  ///
  /// The returned [ApiCallResult] is remapped into a [RawResponse] by the
  /// interceptor so downstream interceptors see a normal response.
  /// Throw/cancel semantics should be avoided — use the result type.
  Future<ApiCallResult> retryRequest(
    RequestSpec request,
    AuthData refreshedAuthData,
  );
}
