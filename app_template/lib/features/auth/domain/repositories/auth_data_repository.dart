import 'dart:async';

import 'package:app_template/features/auth/domain/models/auth_data.dart';
import 'package:app_template/features/auth/domain/models/auth_data_refresh_error.dart';
import 'package:dart_functionals/dart_functionals.dart';
import 'package:net_models/net_models.dart';

abstract interface class AuthDataRepository {
  /// Get the current auth data.
  Future<AuthData?> getCurrentAuthData();

  /// Set current auth data.
  Future<void> setCurrentAuthData(AuthData? authData);

  /// Request an auth data refresh.
  Future<Either<ApiError, Either<AuthDataRefreshError, AuthData>>>
  refreshCurrentAuthData(AuthData authData);

  /// Watch auth data change.
  Stream<AuthData?> getAuthDataStream();

  /// Release any resources held by this repository.
  Future<void> dispose();
}
