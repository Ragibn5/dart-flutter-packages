import 'dart:async';

import 'package:app_template/features/auth/data/models/token_refresh_request.dart';
import 'package:app_template/features/auth/data/repositories/auth_data_mapper.dart';
import 'package:app_template/features/auth/data/repositories/auth_refresh_error_mapper.dart';
import 'package:app_template/features/auth/data/sources/local_auth_data_source.dart';
import 'package:app_template/features/auth/data/sources/remote_auth_data_source.dart';
import 'package:app_template/features/auth/domain/models/auth_data.dart';
import 'package:app_template/features/auth/domain/models/auth_data_refresh_error.dart';
import 'package:app_template/features/auth/domain/repositories/auth_data_repository.dart';
import 'package:dart_functionals/dart_functionals.dart';
import 'package:net_models/net_models.dart';

class AuthDataRepositoryImpl implements AuthDataRepository {
  final StreamController<AuthData?> _authDataStreamController;

  final AuthDataMapper _authDataMapper;
  final AuthRefreshErrorMapper _authRefreshErrorMapper;

  final LocalAuthDataSource _localAuthDataSource;
  final RemoteAuthDataSource _remoteAuthDataSource;

  AuthDataRepositoryImpl(
    this._authDataStreamController,
    this._authDataMapper,
    this._authRefreshErrorMapper,
    this._localAuthDataSource,
    this._remoteAuthDataSource,
  );

  @override
  Future<AuthData?> getCurrentAuthData() async {
    final authDataDTO = await _localAuthDataSource.getCurrentAuthData();
    if (authDataDTO == null) {
      return null;
    }

    return _authDataMapper.convertDataToDomain(authDataDTO);
  }

  @override
  Future<void> setCurrentAuthData(AuthData? authData) {
    // First add to stream to notify listeners
    _authDataStreamController.add(authData);

    // Then add to data source
    return _localAuthDataSource.setCurrentAuthData(
      authData != null ? _authDataMapper.convertDomainToData(authData) : null,
    );
  }

  @override
  Future<Either<ApiError, Either<AuthDataRefreshError, AuthData>>>
  refreshCurrentAuthData(AuthData authData) async {
    final request = TokenRefreshRequest(refreshToken: authData.refreshToken);
    final result = await _remoteAuthDataSource.getRefreshedAuthData(request);
    return result.fold(
      onLeft: Left.new,
      onRight: (r) async => Right(
        await r.fold(
          onLeft: (l) => Left(_authRefreshErrorMapper.convertDataToDomain(l)),
          onRight: (r) async {
            final authData = _authDataMapper.convertDataToDomain(r);
            await setCurrentAuthData(authData);
            return Right(authData);
          },
        ),
      ),
    );
  }

  @override
  Stream<AuthData?> getAuthDataStream() {
    return _authDataStreamController.stream;
  }

  @override
  Future<void> dispose() async {
    await _authDataStreamController.close();
  }
}
