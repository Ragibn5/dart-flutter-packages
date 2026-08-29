import 'dart:io';

import 'package:app_template/features/app/application/use_cases/get_auth_info_use_case.dart';
import 'package:app_template/features/app/application/use_cases/get_refreshed_auth_info_use_case.dart';
import 'package:app_template/features/app/domain/models/auth_info.dart';
import 'package:base_auth_interceptor/base_auth_interceptor.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:net_client/net_client.dart';

/// Interceptor to handle authentication request/response/error.
class AuthInterceptor extends BaseAuthInterceptor<AuthInfo> {
  final NetClient _targetClient;
  final GetAuthInfoUseCase _getAuthInfo;
  final GetRefreshedAuthInfoUseCase _getRefreshedAuthInfo;

  AuthInterceptor(
    this._targetClient,
    this._getAuthInfo,
    this._getRefreshedAuthInfo,
  );

  @override
  Future<AuthInfo?> getAuthData() {
    return _getAuthInfo();
  }

  @override
  Future<RequestSpec> transformRequestWithAuthData(
    RequestSpec request,
    AuthInfo authInfo,
  ) async {
    return request.copyWith(
      headers: {
        ...request.headers,
        ...{HttpHeaders.authorizationHeader: 'Bearer ${authInfo.accessToken}'},
      },
    );
  }

  @override
  bool didServerReportAuthError(RawResponse responses) {
    if (responses.statusCode != HttpStatus.unauthorized) {
      return false;
    }

    final data = responses.rawResponseBody;
    if (data is! Map<String, dynamic>) {
      return false;
    }

    if (data['error_id'] != 'access_token_expired') {
      return false;
    }

    return true;
  }

  @override
  bool shouldRefreshAuthData(RequestSpec request, AuthInfo authInfo) {
    final requestToken = _getRequestToken(request);
    return requestToken == null || requestToken == authInfo.accessToken;
  }

  @override
  Future<AuthInfo?> requestAuthDataRefresh(AuthInfo oldAuthData) async {
    return _getRefreshedAuthInfo();
  }

  @override
  Future<ApiCallResult> retryRequest(
    RequestSpec request,
    AuthInfo refreshedAuthData,
  ) {
    return _targetClient.execute(spec: request);
  }

  /// Iterate through Authorization header splits and return the first
  /// valid token.
  ///
  /// There should always be one token in an 'Authorization' header value,
  /// but there can be prefixes before the actual token (eg. 'Bearer'),
  /// hence, we return the first valid token we find. Will return null
  /// if no valid tokens were found.
  String? _getRequestToken(RequestSpec request) {
    final requestToken = request.headers[HttpHeaders.authorizationHeader];

    if (requestToken == null) {
      return null;
    }

    if (requestToken is! String) {
      return null;
    }

    final splits = requestToken
        .trim()
        .split(RegExp(r'\s+'))
        .map((e) => e.trim());
    for (final split in splits) {
      final decodedToken = JwtDecoder.tryDecode(split);
      if (decodedToken != null) {
        return split;
      }
    }

    return null;
  }
}
