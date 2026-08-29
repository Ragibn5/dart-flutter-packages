import 'package:base_auth_interceptor/src/auth_data_provider.dart';
import 'package:base_auth_interceptor/src/auth_refresh_policy.dart';
import 'package:base_auth_interceptor/src/request_retrier.dart';
import 'package:meta/meta.dart';
import 'package:net_client/net_client.dart';

abstract class BaseAuthInterceptor<AuthData>
    extends QueuedNetClientInterceptor {
  final AuthDataProvider<AuthData> _authDataProvider;
  final AuthRefreshPolicy<AuthData> _refreshPolicy;
  final RequestRetrier<AuthData> _requestRetrier;

  BaseAuthInterceptor(
    this._authDataProvider,
    this._refreshPolicy,
    this._requestRetrier,
  );

  /// Transforms the outgoing [request] with the given [authData].
  ///
  /// Use this to attach any kind of auth data into the request,
  /// such as adding bearer tokens, or any other auth specific
  /// transformation.
  ///
  /// Params:
  /// - [request]: The input request.
  /// - [authData]: The currently available auth data
  ///   obtained from the [AuthDataProvider].
  ///
  /// Returns: A new transformed [RequestSpec] instance,
  /// possibly adapted with the given auth data, which is
  /// sent to the network (or to next interceptor).
  @visibleForOverriding
  Future<RequestSpec> transformRequestWithAuthData(
    RequestSpec request,
    AuthData authData,
  );

  @override
  Future<RequestInterceptorResult> onRequest(RequestSpec request) async {
    final authData = await _authDataProvider.getAuthData();
    if (authData == null) {
      return ShortRequestWithError(
        CancellationException(
          source: '$BaseAuthInterceptor:$onRequest',
          message:
              'Cancelling `${request.method}` request to `${request.uri}`: '
              'Failed to authorize request, auth data unavailable.',
          request: request,
        ),
      );
    }

    final authorizedRequest =
        await transformRequestWithAuthData(request, authData);
    return ContinueWithRequest(authorizedRequest);
  }

  @override
  Future<ResponseInterceptorResult> onResponse(RawResponse response) async {
    if (!_refreshPolicy.didServerReportAuthError(response)) {
      return ContinueWithResponse(response);
    }

    final request = response.request;
    final method = request.method;
    final uri = request.uri;

    final currentAuthData = await _authDataProvider.getAuthData();
    if (currentAuthData == null) {
      return ShortResponseWithError(
        CancellationException(
          source: '$BaseAuthInterceptor:$onResponse',
          message: 'Cancelling `$method` request to `$uri`: '
              'Failed to request auth data refresh (auth data unavailable).',
          request: request,
        ),
      );
    }

    if (!_refreshPolicy.shouldRefreshAuthData(request, currentAuthData)) {
      final response = await _requestRetrier.retryRequest(
        request,
        currentAuthData,
      );
      return response.fold(
        onFailure: (e) => ShortResponseWithError(
          CancellationException(
            source: '$BaseAuthInterceptor:$onResponse',
            message: 'Cancelling `$method` request to `$uri`: '
                'Request retry failed with possibly refreshed auth data.',
            request: request,
          ),
        ),
        onSuccess: (d) => ShortResponseWithFinalResponse(
          RawResponse(
            statusCode: d.statusCode,
            rawResponseBody: d.data,
            responseHeaders: d.headers,
            request: d.requestSpec,
          ),
        ),
      );
    }

    final refreshedAuthData =
        await _authDataProvider.requestAuthDataRefresh(currentAuthData);
    if (refreshedAuthData == null) {
      return ShortResponseWithError(
        CancellationException(
          source: '$BaseAuthInterceptor:$onResponse',
          message: 'Cancelling `$method` request to `$uri`: '
              'Could not refresh auth data.',
          request: request,
        ),
      );
    }

    final retryResponse = await _requestRetrier.retryRequest(
      request,
      refreshedAuthData,
    );
    return retryResponse.fold(
      onFailure: (e) => ShortResponseWithError(
        CancellationException(
          source: '$BaseAuthInterceptor:$onResponse',
          message: 'Cancelling `$method` request to `$uri`: '
              'Failed to retry with refreshed auth data.',
          request: request,
        ),
      ),
      onSuccess: (d) => ShortResponseWithFinalResponse(
        RawResponse(
          statusCode: d.statusCode,
          rawResponseBody: d.data,
          responseHeaders: d.headers,
          request: d.requestSpec,
        ),
      ),
    );
  }
}
