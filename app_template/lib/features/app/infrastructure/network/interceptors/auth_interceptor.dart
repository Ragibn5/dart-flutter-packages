// ignore_for_file: use_super_parameters

import 'package:app_template/features/app/domain/models/auth_info.dart';
import 'package:base_auth_interceptor/base_auth_interceptor.dart';

/// Interceptor to handle authentication request/response/error.
class AuthInterceptor extends BaseAuthInterceptor<AuthInfo> {
  AuthInterceptor(
    AuthDataProvider<AuthInfo> authDataProvider,
    AuthRefreshPolicy<AuthInfo> refreshPolicy,
    AuthRequestTransformer<AuthInfo> requestTransformer,
    RequestRetrier<AuthInfo> requestRetrier,
  ) : super(
        authDataProvider,
        refreshPolicy,
        requestTransformer,
        requestRetrier,
      );
}
