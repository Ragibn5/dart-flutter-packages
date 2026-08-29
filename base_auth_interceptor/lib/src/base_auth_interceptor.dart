import 'package:base_auth_interceptor/src/auth_data_provider.dart';
import 'package:base_auth_interceptor/src/auth_refresh_policy.dart';
import 'package:base_auth_interceptor/src/auth_request_transformer.dart';
import 'package:base_auth_interceptor/src/request_retrier.dart';
import 'package:net_client/net_client.dart';

abstract class BaseAuthInterceptor<AuthData>
    extends QueuedNetClientInterceptor {
  final AuthDataProvider<AuthData> _authDataProvider;
  final AuthRefreshPolicy<AuthData> _refreshPolicy;
  final AuthRequestTransformer<AuthData> _requestTransformer;
  final RequestRetrier<AuthData> _requestRetrier;

  BaseAuthInterceptor(
    this._authDataProvider,
    this._refreshPolicy,
    this._requestTransformer,
    this._requestRetrier,
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

    final authorizedRequest = await _requestTransformer
        .transformRequestWithAuthData(request, authData);
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
