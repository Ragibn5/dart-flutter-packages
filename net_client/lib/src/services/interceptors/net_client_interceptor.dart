import 'package:net_client/net_client.dart';

/// An interceptor for the client.
abstract class NetClientInterceptor {
  /// Intercept the request.
  ///
  /// Called before the request is sent.
  Future<RequestInterceptorResult> onRequest(
    RequestSpec request,
  ) async =>
      ContinueWithRequest(request);

  /// Intercept the response.
  ///
  /// Called after the response is received.
  Future<ResponseInterceptorResult> onResponse(
    RawResponse response,
  ) async =>
      ContinueWithResponse(response);

  /// Intercept the error.
  ///
  /// Called when an error occurs.
  Future<ErrorInterceptorResult> onError(NetClientException error) async =>
      ContinueWithError(error);
}
