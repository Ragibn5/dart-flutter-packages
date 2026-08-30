import 'dart:io';

import 'package:app_template/features/app/domain/models/auth_info.dart';
import 'package:base_auth_interceptor/base_auth_interceptor.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:net_client/net_client.dart';

/// Decides whether a server response indicates an auth error and whether the
/// auth data used for the request should be refreshed.
class AppAuthRefreshPolicy implements AuthRefreshPolicy<AuthInfo> {
  const AppAuthRefreshPolicy();

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
