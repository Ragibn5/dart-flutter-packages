// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:alerty/alerty.dart' as _i69;
import 'package:analytics/analytics.dart' as _i548;
import 'package:app_logger/app_logger.dart' as _i519;
import 'package:app_template/di/modules/app_module.dart' as _i384;
import 'package:app_template/di/modules/auth_module.dart' as _i228;
import 'package:app_template/di/modules/user_data_module.dart' as _i201;
import 'package:app_template/features/app/application/use_cases/get_auth_info_use_case.dart'
    as _i656;
import 'package:app_template/features/app/application/use_cases/get_effective_locale_use_case.dart'
    as _i999;
import 'package:app_template/features/app/application/use_cases/get_effective_theme_mode_use_case.dart'
    as _i363;
import 'package:app_template/features/app/application/use_cases/get_platform_locale_use_case.dart'
    as _i846;
import 'package:app_template/features/app/application/use_cases/get_refreshed_auth_info_use_case.dart'
    as _i641;
import 'package:app_template/features/app/application/use_cases/get_settings_use_case.dart'
    as _i393;
import 'package:app_template/features/app/application/use_cases/initialize_app_use_case.dart'
    as _i656;
import 'package:app_template/features/app/application/use_cases/initialize_session_use_case.dart'
    as _i1052;
import 'package:app_template/features/app/application/use_cases/is_authed_use_case.dart'
    as _i97;
import 'package:app_template/features/app/application/use_cases/set_settings_use_case.dart'
    as _i78;
import 'package:app_template/features/app/application/use_cases/watch_auth_state_use_case.dart'
    as _i884;
import 'package:app_template/features/app/application/use_cases/watch_locale_use_case.dart'
    as _i625;
import 'package:app_template/features/app/application/use_cases/watch_settings_use_case.dart'
    as _i170;
import 'package:app_template/features/app/application/use_cases/watch_theme_mode_use_case.dart'
    as _i44;
import 'package:app_template/features/app/data/models/settings_dto.dart'
    as _i913;
import 'package:app_template/features/app/data/sources/settings_data_source.dart'
    as _i1014;
import 'package:app_template/features/app/domain/models/app_settings.dart'
    as _i233;
import 'package:app_template/features/app/domain/repositories/settings_repository.dart'
    as _i1030;
import 'package:app_template/features/app/domain/services/app_locale_resolver.dart'
    as _i791;
import 'package:app_template/features/app/domain/services/local_components_mapper.dart'
    as _i1034;
import 'package:app_template/features/app/infrastructure/models/app_directories.dart'
    as _i527;
import 'package:app_template/features/app/infrastructure/models/build_metadata.dart'
    as _i143;
import 'package:app_template/features/app/infrastructure/models/flavor_config.dart'
    as _i821;
import 'package:app_template/features/app/infrastructure/services/app_config_factory.dart'
    as _i803;
import 'package:app_template/features/app/infrastructure/services/fallback_locale_selector.dart'
    as _i291;
import 'package:app_template/features/app/presentation/bloc/app_root_bloc.dart'
    as _i873;
import 'package:app_template/features/auth/application/use_cases/get_auth_data_use_case.dart'
    as _i969;
import 'package:app_template/features/auth/application/use_cases/refresh_auth_data_use_case.dart'
    as _i930;
import 'package:app_template/features/auth/application/use_cases/set_auth_data_use_case.dart'
    as _i21;
import 'package:app_template/features/auth/application/use_cases/watch_auth_data_use_case.dart'
    as _i692;
import 'package:app_template/features/auth/data/clients/app_server_token_refresh_api_client.dart'
    as _i524;
import 'package:app_template/features/auth/data/repositories/auth_data_mapper.dart'
    as _i704;
import 'package:app_template/features/auth/data/repositories/auth_refresh_error_mapper.dart'
    as _i82;
import 'package:app_template/features/auth/data/sources/local_auth_data_source.dart'
    as _i30;
import 'package:app_template/features/auth/data/sources/remote_auth_data_source.dart'
    as _i156;
import 'package:app_template/features/auth/domain/repositories/auth_data_repository.dart'
    as _i731;
import 'package:app_template/features/user_data/data/models/user_data_dto.dart'
    as _i1018;
import 'package:app_template/features/user_data/data/sources/user_data_data_source.dart'
    as _i257;
import 'package:app_template/features/user_data/domain/models/user_data.dart'
    as _i436;
import 'package:app_template/features/user_data/domain/repositories/user_data_repository.dart'
    as _i728;
import 'package:app_template/features/user_data/domain/services/user_data_service.dart'
    as _i84;
import 'package:crashlytics/crashlytics.dart' as _i35;
import 'package:data_domain_converters/data_domain_converters.dart' as _i1003;
import 'package:flutter/material.dart' as _i409;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:loghub/loghub.dart' as _i642;
import 'package:nav_router/nav_router.dart' as _i251;
import 'package:net_kit/net_kit.dart' as _i535;
import 'package:package_info_plus/package_info_plus.dart' as _i655;
import 'package:preference_store/preference_store.dart' as _i300;
import 'package:snacker/snacker.dart' as _i1020;
import 'package:sqlite_db/sqlite_db.dart' as _i860;

const String _stage = 'stage';
const String _dev = 'dev';
const String _exp = 'exp';
const String _prod = 'prod';

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    final authModule = _$AuthModule();
    final userDataModule = _$UserDataModule();
    gh.factory<_i791.AppLocaleResolver>(() => appModule.getAppLocaleResolver());
    gh.factory<_i1034.LocalComponentsMapper>(
      () => appModule.getLocalComponentsMapper(),
    );
    gh.factory<_i291.FallbackLocaleSelector>(
      () => appModule.getFallbackLocaleSelector(),
    );
    gh.factory<
      _i1003.DataDomainConverter<_i913.SettingsDTO, _i233.AppSettings>
    >(() => appModule.getSettingsMapper());
    gh.factory<_i846.GetPlatformLocaleUseCase>(
      () => appModule.getPlatformLocaleUseCase(),
    );
    gh.factory<_i548.AnalyticsService>(() => appModule.getAnalyticsService());
    gh.factory<_i35.CrashlyticsService>(
      () => appModule.getCrashlyticsService(),
    );
    gh.factory<_i704.AuthDataMapper>(() => authModule.getAuthDataMapper());
    gh.factory<_i82.AuthRefreshErrorMapper>(
      () => authModule.getAuthRefreshErrorMapper(),
    );
    gh.factory<_i1003.DataDomainConverter<_i1018.UserDataDTO, _i436.UserData>>(
      () => userDataModule.getUserDataMapper(),
    );
    await gh.singletonAsync<_i655.PackageInfo>(
      () => appModule.getPackageInfo(),
      preResolve: true,
    );
    await gh.singletonAsync<_i527.AppDirectories>(
      () => appModule.getAppDirectories(),
      preResolve: true,
    );
    gh.singleton<_i409.GlobalKey<_i409.NavigatorState>>(
      () => appModule.getGlobalNavigatorState(),
    );
    gh.singleton<_i409.GlobalKey<_i409.ScaffoldMessengerState>>(
      () => appModule.getGlobalScaffoldMessengerState(),
    );
    gh.singleton<_i642.LogPolicyController>(
      () => appModule.getLogPolicyController(),
    );
    gh.singleton<_i300.PreferenceStore>(
      () => appModule.getSharedPreferenceStore(),
    );
    gh.singleton<_i821.FlavorConfig>(
      () => appModule.getStageFlavorConfig(),
      registerFor: {_stage},
    );
    gh.singleton<_i821.FlavorConfig>(
      () => appModule.getDevFlavorConfig(),
      registerFor: {_dev},
    );
    gh.singleton<_i821.FlavorConfig>(
      () => appModule.getExpFlavorConfig(),
      registerFor: {_exp},
    );
    gh.factory<_i803.AppConfigFactory>(
      () => appModule.getAppConfigFactory(
        gh<_i655.PackageInfo>(),
        gh<_i291.FallbackLocaleSelector>(),
      ),
    );
    gh.singleton<_i519.AppLogger>(
      () => appModule.getLogger(
        gh<_i527.AppDirectories>(),
        gh<_i642.LogPolicyController>(),
      ),
    );
    gh.factory<_i69.Alerty>(
      () => appModule.getAlerty(gh<_i409.GlobalKey<_i409.NavigatorState>>()),
    );
    gh.singleton<_i821.FlavorConfig>(
      () => appModule.getProdFlavorConfig(),
      registerFor: {_prod},
    );
    gh.singleton<_i1014.SettingsDataSource>(
      () => appModule.getSettingsDataSource(gh<_i300.PreferenceStore>()),
    );
    gh.factory<_i30.LocalAuthDataSource>(
      () => authModule.getLocalAuthDataSource(gh<_i300.PreferenceStore>()),
    );
    gh.singleton<_i860.SQLiteDb>(
      () => appModule.getAppDatabase(gh<_i527.AppDirectories>()),
      dispose: _i384.disposeAppDatabase,
    );
    gh.factory<_i1020.Snacker>(
      () => appModule.getSnacker(
        gh<_i409.GlobalKey<_i409.ScaffoldMessengerState>>(),
      ),
    );
    gh.factory<_i656.InitializeAppUseCase>(
      () => appModule.getAppInitializerUseCase(
        gh<_i548.AnalyticsService>(),
        gh<_i35.CrashlyticsService>(),
        gh<_i860.SQLiteDb>(),
      ),
    );
    gh.factory<_i143.BuildMetadata>(
      () => appModule.getBuildMetadata(
        gh<_i821.FlavorConfig>(),
        gh<_i655.PackageInfo>(),
      ),
    );
    gh.factory<_i257.UserDataDataSource>(
      () => userDataModule.getUserDataDataSource(gh<_i860.SQLiteDb>()),
    );
    gh.singleton<_i1030.SettingsRepository>(
      () => appModule.getSettingsRepository(
        gh<_i1003.DataDomainConverter<_i913.SettingsDTO, _i233.AppSettings>>(),
        gh<_i1014.SettingsDataSource>(),
      ),
      dispose: _i384.disposeSettingsRepository,
    );
    gh.factory<_i625.WatchLocaleUseCase>(
      () => appModule.getWatchLocaleUseCase(
        gh<_i1030.SettingsRepository>(),
        gh<_i1034.LocalComponentsMapper>(),
      ),
    );
    gh.factory<_i728.UserDataRepository>(
      () => userDataModule.getUserDataRepository(
        gh<_i1003.DataDomainConverter<_i1018.UserDataDTO, _i436.UserData>>(),
        gh<_i257.UserDataDataSource>(),
      ),
    );
    gh.factory<_i999.GetEffectiveLocaleUseCase>(
      () => appModule.getGetEffectiveLocaleUseCase(
        gh<_i791.AppLocaleResolver>(),
        gh<_i1030.SettingsRepository>(),
        gh<_i846.GetPlatformLocaleUseCase>(),
      ),
    );
    gh.factory<_i44.WatchThemeModeUseCase>(
      () => appModule.getWatchThemeModeUseCase(gh<_i1030.SettingsRepository>()),
    );
    gh.factory<_i363.GetEffectiveThemeModeUseCase>(
      () => appModule.getGetEffectiveThemeModeUseCase(
        gh<_i1030.SettingsRepository>(),
      ),
    );
    gh.factory<_i84.UserDataService>(
      () => userDataModule.getUserDataService(gh<_i728.UserDataRepository>()),
    );
    gh.factory<_i393.GetSettingsUseCase>(
      () => appModule.getGetSettingsUseCase(gh<_i1030.SettingsRepository>()),
    );
    gh.factory<_i78.SetSettingsUseCase>(
      () => appModule.getSetSettingsUseCase(gh<_i1030.SettingsRepository>()),
    );
    gh.factory<_i170.WatchSettingsUseCase>(
      () => appModule.getWatchSettingsUseCase(gh<_i1030.SettingsRepository>()),
    );
    gh.factory<_i524.AppServerTokenRefreshApiClient>(
      () => appModule.getAppServerTokenRefresherApiClient(
        gh<_i821.FlavorConfig>(),
        gh<_i143.BuildMetadata>(),
        gh<_i519.AppLogger>(),
        gh<_i999.GetEffectiveLocaleUseCase>(),
      ),
    );
    gh.singleton<_i535.NetClient>(
      () => appModule.getAppServerPublicApiClient(
        gh<_i821.FlavorConfig>(),
        gh<_i143.BuildMetadata>(),
        gh<_i999.GetEffectiveLocaleUseCase>(),
        gh<_i519.AppLogger>(),
      ),
      instanceName: 'APP_SERVER_PUBLIC_API_CLIENT',
      dispose: _i384.disposeNetClient,
    );
    gh.factory<_i156.RemoteAuthDataSource>(
      () => authModule.getRemoteAuthDataSource(
        gh<_i524.AppServerTokenRefreshApiClient>(),
      ),
    );
    gh.singleton<_i731.AuthDataRepository>(
      () => authModule.getAuthDataRepository(
        gh<_i704.AuthDataMapper>(),
        gh<_i82.AuthRefreshErrorMapper>(),
        gh<_i30.LocalAuthDataSource>(),
        gh<_i156.RemoteAuthDataSource>(),
      ),
      dispose: _i228.disposeAuthDataRepository,
    );
    gh.factory<_i969.GetAuthDataUseCase>(
      () => authModule.getGetAuthDataUseCase(gh<_i731.AuthDataRepository>()),
    );
    gh.factory<_i21.SetAuthDataUseCase>(
      () => authModule.getSetAuthDataUseCase(gh<_i731.AuthDataRepository>()),
    );
    gh.factory<_i692.WatchAuthDataUseCase>(
      () => authModule.getWatchAuthDataUseCase(gh<_i731.AuthDataRepository>()),
    );
    gh.factory<_i930.RefreshAuthDataUseCase>(
      () =>
          authModule.getRefreshAuthDataUseCase(gh<_i731.AuthDataRepository>()),
    );
    gh.factory<_i884.WatchAuthStateUseCase>(
      () =>
          appModule.getWatchAuthStateUseCase(gh<_i692.WatchAuthDataUseCase>()),
    );
    gh.factory<_i641.GetRefreshedAuthInfoUseCase>(
      () => appModule.getGetRefreshedAuthInfoUseCase(
        gh<_i930.RefreshAuthDataUseCase>(),
      ),
    );
    gh.factory<_i97.IsAuthedUseCase>(
      () => appModule.getIsAuthedUseCase(gh<_i969.GetAuthDataUseCase>()),
    );
    gh.factory<_i656.GetAuthInfoUseCase>(
      () => appModule.getGetAuthInfoUseCase(gh<_i969.GetAuthDataUseCase>()),
    );
    gh.factory<_i1052.InitializeSessionUseCase>(
      () =>
          appModule.getInitializeSessionUseCase(gh<_i969.GetAuthDataUseCase>()),
    );
    gh.singleton<_i873.AppRootBloc>(
      () => appModule.getAppRootBloc(
        gh<_i519.AppLogger>(),
        gh<_i884.WatchAuthStateUseCase>(),
        gh<_i625.WatchLocaleUseCase>(),
        gh<_i44.WatchThemeModeUseCase>(),
        gh<_i999.GetEffectiveLocaleUseCase>(),
        gh<_i363.GetEffectiveThemeModeUseCase>(),
        gh<_i656.InitializeAppUseCase>(),
        gh<_i1052.InitializeSessionUseCase>(),
      ),
    );
    gh.singleton<_i535.NetClient>(
      () => appModule.getAppServerPrivateApiClient(
        gh<_i821.FlavorConfig>(),
        gh<_i143.BuildMetadata>(),
        gh<_i519.AppLogger>(),
        gh<_i656.GetAuthInfoUseCase>(),
        gh<_i641.GetRefreshedAuthInfoUseCase>(),
        gh<_i999.GetEffectiveLocaleUseCase>(),
        gh<_i524.AppServerTokenRefreshApiClient>(),
      ),
      instanceName: 'APP_SERVER_PRIVATE_API_CLIENT',
      dispose: _i384.disposeNetClient,
    );
    gh.singleton<_i251.NavRouter>(
      () => appModule.getAppRouter(
        gh<_i409.GlobalKey<_i409.NavigatorState>>(),
        gh<_i97.IsAuthedUseCase>(),
      ),
    );
    return this;
  }
}

class _$AppModule extends _i384.AppModule {}

class _$AuthModule extends _i228.AuthModule {}

class _$UserDataModule extends _i201.UserDataModule {}
