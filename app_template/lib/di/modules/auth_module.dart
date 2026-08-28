import 'dart:async';

import 'package:app_template/features/auth/application/use_cases/get_auth_data_use_case.dart';
import 'package:app_template/features/auth/application/use_cases/refresh_auth_data_use_case.dart';
import 'package:app_template/features/auth/application/use_cases/set_auth_data_use_case.dart';
import 'package:app_template/features/auth/application/use_cases/watch_auth_data_use_case.dart';
import 'package:app_template/features/auth/data/clients/app_server_token_refresh_api_client.dart';
import 'package:app_template/features/auth/data/repositories/auth_data_mapper.dart';
import 'package:app_template/features/auth/data/repositories/auth_data_repository_impl.dart';
import 'package:app_template/features/auth/data/repositories/auth_refresh_error_mapper.dart';
import 'package:app_template/features/auth/data/sources/local_auth_data_source.dart';
import 'package:app_template/features/auth/data/sources/local_auth_data_source_impl.dart';
import 'package:app_template/features/auth/data/sources/remote_auth_data_source.dart';
import 'package:app_template/features/auth/data/sources/remote_auth_data_source_impl.dart';
import 'package:app_template/features/auth/domain/repositories/auth_data_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:preference_store/preference_store.dart';

@module
abstract class AuthModule {
  AuthDataMapper getAuthDataMapper() {
    return AuthDataMapper();
  }

  AuthRefreshErrorMapper getAuthRefreshErrorMapper() {
    return AuthRefreshErrorMapper();
  }

  RemoteAuthDataSource getRemoteAuthDataSource(
    AppServerTokenRefreshApiClient client,
  ) {
    return RemoteAuthDataSourceImpl(client);
  }

  LocalAuthDataSource getLocalAuthDataSource(PreferenceStore preferenceStore) {
    return LocalAuthDataSourceImpl(preferenceStore);
  }

  @Singleton(dispose: disposeAuthDataRepository)
  AuthDataRepository getAuthDataRepository(
    AuthDataMapper authDataMapper,
    AuthRefreshErrorMapper authRefreshErrorMapper,
    LocalAuthDataSource localAuthDataSource,
    RemoteAuthDataSource remoteAuthDataSource,
  ) {
    return AuthDataRepositoryImpl(
      StreamController.broadcast(),
      authDataMapper,
      authRefreshErrorMapper,
      localAuthDataSource,
      remoteAuthDataSource,
    );
  }

  GetAuthDataUseCase getGetAuthDataUseCase(AuthDataRepository repository) {
    return GetAuthDataUseCase(repository);
  }

  SetAuthDataUseCase getSetAuthDataUseCase(AuthDataRepository repository) {
    return SetAuthDataUseCase(repository);
  }

  WatchAuthDataUseCase getWatchAuthDataUseCase(AuthDataRepository repository) {
    return WatchAuthDataUseCase(repository);
  }

  RefreshAuthDataUseCase getRefreshAuthDataUseCase(
    AuthDataRepository repository,
  ) {
    return RefreshAuthDataUseCase(repository);
  }
}

FutureOr<dynamic> disposeAuthDataRepository(AuthDataRepository repository) {
  repository.dispose();
}
