import 'package:app_template/features/app/application/use_cases/get_auth_info_use_case.dart';
import 'package:app_template/features/app/application/use_cases/get_refreshed_auth_info_use_case.dart';
import 'package:app_template/features/app/domain/models/auth_info.dart';
import 'package:base_auth_interceptor/base_auth_interceptor.dart';

/// Provides current and refreshed auth data for the auth interceptor.
class AppAuthDataProvider implements AuthDataProvider<AuthInfo> {
  final GetAuthInfoUseCase _getAuthInfo;
  final GetRefreshedAuthInfoUseCase _getRefreshedAuthInfo;

  AppAuthDataProvider(this._getAuthInfo, this._getRefreshedAuthInfo);

  @override
  Future<AuthInfo?> getAuthData() => _getAuthInfo();

  @override
  Future<AuthInfo?> requestAuthDataRefresh(AuthInfo oldAuthData) =>
      _getRefreshedAuthInfo();
}
