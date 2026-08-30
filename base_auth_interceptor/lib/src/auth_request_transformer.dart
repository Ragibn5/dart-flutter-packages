import 'package:net_client/net_client.dart';

/// Applies auth data to an outgoing request.
abstract interface class AuthRequestTransformer<AuthData> {
  /// Transforms the outgoing [request] with the given [authData].
  ///
  /// Use this to attach any kind of auth data into the request,
  /// such as adding bearer tokens, or any other auth specific
  /// transformation.
  ///
  /// Params:
  /// - [request]: The input request.
  /// - [authData]: The currently available auth data.
  ///
  /// Returns: A new transformed [RequestSpec] instance,
  /// possibly adapted with the given auth data, which is
  /// sent to the network (or to next interceptor).
  Future<RequestSpec> transformRequestWithAuthData(
    RequestSpec request,
    AuthData authData,
  );
}
