import 'dart:io';

import 'package:app_template/features/app/domain/models/auth_info.dart';
import 'package:base_auth_interceptor/base_auth_interceptor.dart';
import 'package:net_client/net_client.dart';

/// Adds the bearer access token to outgoing requests.
class AppAuthRequestTransformer implements AuthRequestTransformer<AuthInfo> {
  const AppAuthRequestTransformer();

  @override
  Future<RequestSpec> transformRequestWithAuthData(
    RequestSpec request,
    AuthInfo authInfo,
  ) async => request.copyWith(
    headers: {
      ...request.headers,
      ...{HttpHeaders.authorizationHeader: 'Bearer ${authInfo.accessToken}'},
    },
  );
}
