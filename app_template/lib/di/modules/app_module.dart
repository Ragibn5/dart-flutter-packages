import 'dart:async';
import 'dart:io';

import 'package:alerty/alerty.dart';
import 'package:analytics/analytics.dart';
import 'package:app_logger/app_logger.dart';
import 'package:app_template/features/app/application/use_cases/get_auth_info_use_case.dart';
import 'package:app_template/features/app/application/use_cases/get_effective_locale_use_case.dart';
import 'package:app_template/features/app/application/use_cases/get_effective_theme_mode_use_case.dart';
import 'package:app_template/features/app/application/use_cases/get_platform_locale_use_case.dart';
import 'package:app_template/features/app/application/use_cases/get_refreshed_auth_info_use_case.dart';
import 'package:app_template/features/app/application/use_cases/get_settings_use_case.dart';
import 'package:app_template/features/app/application/use_cases/initialize_app_use_case.dart';
import 'package:app_template/features/app/application/use_cases/initialize_session_use_case.dart';
import 'package:app_template/features/app/application/use_cases/is_authed_use_case.dart';
import 'package:app_template/features/app/application/use_cases/set_settings_use_case.dart';
import 'package:app_template/features/app/application/use_cases/watch_auth_state_use_case.dart';
import 'package:app_template/features/app/application/use_cases/watch_locale_use_case.dart';
import 'package:app_template/features/app/application/use_cases/watch_settings_use_case.dart';
import 'package:app_template/features/app/application/use_cases/watch_theme_mode_use_case.dart';
import 'package:app_template/features/app/data/mappers/settings_mapper.dart';
import 'package:app_template/features/app/data/models/settings_dto.dart';
import 'package:app_template/features/app/data/repositories/settings_repository_impl.dart';
import 'package:app_template/features/app/data/sources/settings_data_source.dart';
import 'package:app_template/features/app/data/sources/settings_data_source_impl.dart';
import 'package:app_template/features/app/domain/models/app_settings.dart';
import 'package:app_template/features/app/domain/repositories/settings_repository.dart';
import 'package:app_template/features/app/domain/services/app_locale_resolver.dart';
import 'package:app_template/features/app/domain/services/local_components_mapper.dart';
import 'package:app_template/features/app/infrastructure/config/router/routes.dart';
import 'package:app_template/features/app/infrastructure/enums/app_flavor.dart';
import 'package:app_template/features/app/infrastructure/enums/app_route.dart';
import 'package:app_template/features/app/infrastructure/models/app_directories.dart';
import 'package:app_template/features/app/infrastructure/models/build_metadata.dart';
import 'package:app_template/features/app/infrastructure/models/flavor_config.dart';
import 'package:app_template/features/app/infrastructure/network/interceptors/auth_interceptor.dart';
import 'package:app_template/features/app/infrastructure/network/interceptors/logger_interceptor.dart';
import 'package:app_template/features/app/infrastructure/network/interceptors/metadata_adder_interceptor.dart';
import 'package:app_template/features/app/infrastructure/ports/get_auth_info_use_case_impl.dart';
import 'package:app_template/features/app/infrastructure/ports/get_platform_locale_use_case.dart';
import 'package:app_template/features/app/infrastructure/ports/get_refreshed_auth_info_use_case_impl.dart';
import 'package:app_template/features/app/infrastructure/ports/get_user_id_use_case_impl.dart';
import 'package:app_template/features/app/infrastructure/ports/is_authed_use_case_impl.dart';
import 'package:app_template/features/app/infrastructure/ports/set_analytics_session_data_use_case_impl.dart';
import 'package:app_template/features/app/infrastructure/ports/set_crashlytics_session_data_use_case_impl.dart';
import 'package:app_template/features/app/infrastructure/ports/watch_auth_state_use_case_impl.dart';
import 'package:app_template/features/app/infrastructure/router/guards/router_logger.dart';
import 'package:app_template/features/app/infrastructure/services/app_config_factory.dart';
import 'package:app_template/features/app/infrastructure/services/fallback_locale_selector.dart';
import 'package:app_template/features/app/presentation/bloc/app_root_bloc.dart';
import 'package:app_template/features/auth/application/use_cases/get_auth_data_use_case.dart';
import 'package:app_template/features/auth/application/use_cases/refresh_auth_data_use_case.dart';
import 'package:app_template/features/auth/application/use_cases/watch_auth_data_use_case.dart';
import 'package:app_template/features/auth/data/clients/app_server_token_refresh_api_client.dart';
import 'package:app_template/features/auth/infrastructure/network/clients/app_server_token_refresh_api_client_impl.dart';
import 'package:app_template/features/user_data/infrastructure/database/constants/user_data_table_constants.dart';
import 'package:crashlytics/crashlytics.dart';
import 'package:data_domain_converters/data_domain_converters.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:loghub/loghub.dart' hide Logger;
import 'package:nav_router/nav_router.dart';
import 'package:net_kit/net_kit.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:preference_store/preference_store.dart';
import 'package:snacker/snacker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlite_db/sqlite_db.dart';

const String APP_SERVER_PUBLIC_API_CLIENT = 'APP_SERVER_PUBLIC_API_CLIENT';
const String APP_SERVER_PRIVATE_API_CLIENT = 'APP_SERVER_PRIVATE_API_CLIENT';

@module
abstract class AppModule {
  @Singleton(env: [AppFlavor.FLAVOR_NAME_DEV])
  FlavorConfig getDevFlavorConfig() {
    return FlavorConfig(
      flavor: AppFlavor.DEV.name,
      baseUrl: 'https://dev.yourserver.com',
      storageBucketUrl: 'https://dev.yourbucket.com',
    );
  }

  @Singleton(env: [AppFlavor.FLAVOR_NAME_EXP])
  FlavorConfig getExpFlavorConfig() {
    return FlavorConfig(
      flavor: AppFlavor.EXP.name,
      baseUrl: 'https://exp.yourserver.com',
      storageBucketUrl: 'https://exp.yourbucket.com',
    );
  }

  @Singleton(env: [AppFlavor.FLAVOR_NAME_STAGE])
  FlavorConfig getStageFlavorConfig() {
    return FlavorConfig(
      flavor: AppFlavor.STAGE.name,
      baseUrl: 'https://stage.yourserver.com',
      storageBucketUrl: 'https://stage.yourbucket.com',
    );
  }

  @Singleton(env: [AppFlavor.FLAVOR_NAME_PROD])
  FlavorConfig getProdFlavorConfig() {
    return FlavorConfig(
      flavor: AppFlavor.PROD.name,
      baseUrl: 'https://yourserver.com',
      storageBucketUrl: 'https://yourbucket.com',
    );
  }

  @singleton
  @preResolve
  Future<PackageInfo> getPackageInfo() {
    return PackageInfo.fromPlatform();
  }

  @singleton
  @preResolve
  Future<AppDirectories> getAppDirectories() async {
    return AppDirectories(
      logDirectory: Directory(
        path.join((await getApplicationCacheDirectory()).path, 'logs'),
      ),
      databaseDirectory: Directory(await getDatabasesPath()),
    );
  }

  BuildMetadata getBuildMetadata(
    FlavorConfig flavorConfig,
    PackageInfo packageInfo,
  ) {
    return BuildMetadata(
      scope: 'flutter',
      platform: Platform.operatingSystem,
      platformVersion: Platform.operatingSystemVersion,
      runtime: 'dart',
      runtimeVersion: Platform.version,
      packageName: packageInfo.packageName,
      flavor: flavorConfig.flavor,
      versionName: packageInfo.version,
      versionCode: packageInfo.buildNumber,
    );
  }

  @singleton
  GlobalKey<NavigatorState> getGlobalNavigatorState() {
    return GlobalKey<NavigatorState>();
  }

  @singleton
  GlobalKey<ScaffoldMessengerState> getGlobalScaffoldMessengerState() {
    return GlobalKey<ScaffoldMessengerState>();
  }

  @singleton
  LogPolicyController getLogPolicyController() {
    return DefaultLogPolicyController();
  }

  @singleton
  AppLogger getLogger(
    AppDirectories appDirectories,
    LogPolicyController logPolicyController,
  ) {
    return const AppLoggerFactory().create(
      filters: [PolicyBasedLogFilter(logPolicyController)],
      loggers: {
        'console': ConsoleLogger(),
        'file': FileLogger(
          logDirectory: appDirectories.logDirectory,
          fileNameBuilder: (data) =>
              'LOG-${DateFormat('dd-MM-yyyy').format(data.stamp)}.log',
        ),
      },
    );
  }

  @singleton
  PreferenceStore getSharedPreferenceStore() {
    return const PreferenceStoreFactory().create();
  }

  @Singleton(dispose: disposeAppDatabase)
  SQLiteDb getAppDatabase(AppDirectories appDirectories) {
    const appDbVersion = 1;
    const appDbName = 'APP_DB';

    String escape(String identifier) {
      return '"${identifier.replaceAll('"', '""')}"';
    }

    return const SQLiteDbFactory().create(
      DbConnectionData(
        hostDirectoryPath: path.join(
          appDirectories.databaseDirectory.path,
          appDbName,
        ),
        name: appDbName,
        version: appDbVersion,
      ),
      DbInitializerScripts(
        creationScripts: [
          SingleVersionedDbScript(
            targetVersion: appDbVersion,
            scriptText:
                '''
                CREATE TABLE ${escape(UserDataTableConstants.NAME)} (
                  ${escape(UserDataTableConstants.COLUMN_ID)} TEXT NOT NULL UNIQUE,
                  ${escape(UserDataTableConstants.COLUMN_NAME)} TEXT NOT NULL,
                  PRIMARY KEY(${escape(UserDataTableConstants.COLUMN_ID)})
                );
                ''',
          ),
        ],
      ),
    );
  }

  AppLocaleResolver getAppLocaleResolver() {
    return AppLocaleResolver();
  }

  LocalComponentsMapper getLocalComponentsMapper() {
    return LocalComponentsMapper();
  }

  FallbackLocaleSelector getFallbackLocaleSelector() {
    return const FallbackLocaleSelector();
  }

  DataDomainConverter<SettingsDTO, AppSettings> getSettingsMapper() {
    return SettingsMapper();
  }

  @singleton
  SettingsDataSource getSettingsDataSource(PreferenceStore preferenceStore) {
    return SettingsDataSourceImpl(preferenceStore);
  }

  @Singleton(dispose: disposeSettingsRepository)
  SettingsRepository getSettingsRepository(
    DataDomainConverter<SettingsDTO, AppSettings> settingsMapper,
    SettingsDataSource settingsDataSource,
  ) {
    return SettingsRepositoryImpl(
      StreamController<AppSettings>.broadcast(),
      settingsMapper,
      settingsDataSource,
    );
  }

  GetPlatformLocaleUseCase getPlatformLocaleUseCase() {
    return GetPlatformLocaleUseCaseImpl(WidgetsBinding.instance);
  }

  IsAuthedUseCase getIsAuthedUseCase(GetAuthDataUseCase getAuthDataUseCase) {
    return IsAuthedUseCaseImpl(getAuthDataUseCase);
  }

  GetAuthInfoUseCase getGetAuthInfoUseCase(
    GetAuthDataUseCase getAuthDataUseCase,
  ) {
    return GetAuthInfoUseCaseImpl(getAuthDataUseCase);
  }

  GetRefreshedAuthInfoUseCase getGetRefreshedAuthInfoUseCase(
    RefreshAuthDataUseCase refreshAuthDataUseCase,
  ) {
    return GetRefreshedAuthInfoUseCaseImpl(refreshAuthDataUseCase);
  }

  WatchAuthStateUseCase getWatchAuthStateUseCase(
    WatchAuthDataUseCase watchAuthDataUseCase,
  ) {
    return WatchAuthStateUseCaseImpl(watchAuthDataUseCase);
  }

  @injectable
  GetSettingsUseCase getGetSettingsUseCase(SettingsRepository repository) {
    return GetSettingsUseCase(repository);
  }

  @injectable
  SetSettingsUseCase getSetSettingsUseCase(SettingsRepository repository) {
    return SetSettingsUseCase(repository);
  }

  @injectable
  WatchSettingsUseCase getWatchSettingsUseCase(SettingsRepository repository) {
    return WatchSettingsUseCase(repository);
  }

  @injectable
  WatchThemeModeUseCase getWatchThemeModeUseCase(
    SettingsRepository settingsRepository,
  ) {
    return WatchThemeModeUseCase(settingsRepository);
  }

  @injectable
  WatchLocaleUseCase getWatchLocaleUseCase(
    SettingsRepository settingsRepository,
    LocalComponentsMapper localComponentsMapper,
  ) {
    return WatchLocaleUseCase(settingsRepository, localComponentsMapper);
  }

  @injectable
  GetEffectiveLocaleUseCase getGetEffectiveLocaleUseCase(
    AppLocaleResolver appLocaleResolver,
    SettingsRepository settingsRepository,
    GetPlatformLocaleUseCase getPlatformLocale,
  ) {
    return GetEffectiveLocaleUseCase(
      settingsRepository,
      appLocaleResolver,
      getPlatformLocale,
    );
  }

  @injectable
  GetEffectiveThemeModeUseCase getGetEffectiveThemeModeUseCase(
    SettingsRepository settingsRepository,
  ) {
    return GetEffectiveThemeModeUseCase(settingsRepository);
  }

  @Singleton(dispose: disposeNetClient)
  @Named(APP_SERVER_PUBLIC_API_CLIENT)
  NetClient getAppServerPublicApiClient(
    FlavorConfig flavorConfig,
    BuildMetadata buildMetadata,
    GetEffectiveLocaleUseCase getEffectiveLocale,
    AppLogger logger,
  ) {
    final client = NetClientFactory().create(
      ClientConfig(
        baseUrl: flavorConfig.baseUrl,
        connectionTimeout: const Duration(seconds: 10),
      ),
    );

    client.interceptors.addAll([
      MetadataAdderInterceptor(buildMetadata, getEffectiveLocale),
      LoggerInterceptor(logger),
    ]);

    return client;
  }

  @Singleton(dispose: disposeNetClient)
  @Named(APP_SERVER_PRIVATE_API_CLIENT)
  NetClient getAppServerPrivateApiClient(
    FlavorConfig flavorConfig,
    BuildMetadata buildMetadata,
    AppLogger logger,
    GetAuthInfoUseCase getAuthInfo,
    GetRefreshedAuthInfoUseCase getRefreshedAuthInfo,
    GetEffectiveLocaleUseCase getEffectiveLocale,
    AppServerTokenRefreshApiClient tokenRefreshApiClient,
  ) {
    final client = NetClientFactory().create(
      ClientConfig(
        baseUrl: flavorConfig.baseUrl,
        connectionTimeout: const Duration(seconds: 10),
      ),
    );

    client.interceptors.addAll([
      MetadataAdderInterceptor(buildMetadata, getEffectiveLocale),
      AuthInterceptor(client, getAuthInfo, getRefreshedAuthInfo),
      LoggerInterceptor(logger),
    ]);

    return client;
  }

  AppServerTokenRefreshApiClient getAppServerTokenRefresherApiClient(
    FlavorConfig flavorConfig,
    BuildMetadata buildMetadata,
    AppLogger logger,
    GetEffectiveLocaleUseCase getEffectiveLocale,
  ) {
    final client = NetClientFactory().create(
      ClientConfig(
        baseUrl: flavorConfig.baseUrl,
        connectionTimeout: const Duration(seconds: 10),
      ),
    );

    client.interceptors.addAll([
      MetadataAdderInterceptor(buildMetadata, getEffectiveLocale),
      LoggerInterceptor(logger),
    ]);

    return AppServerTokenRefreshApiClientImpl(client);
  }

  Alerty getAlerty(GlobalKey<NavigatorState> navigatorKey) {
    return RouterNavigatorAlerty(navigatorKey);
  }

  AnalyticsService getAnalyticsService() {
    return FirebaseAnalyticsService(FirebaseAnalytics.instance);
  }

  CrashlyticsService getCrashlyticsService() {
    return FirebaseCrashlyticsService(FirebaseCrashlytics.instance);
  }

  Snacker getSnacker(GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey) {
    return ScaffoldMessengerSnacker(scaffoldMessengerKey);
  }

  AppConfigFactory getAppConfigFactory(
    PackageInfo packageInfo,
    FallbackLocaleSelector fallbackLocaleSelector,
  ) {
    return AppConfigFactory(packageInfo, fallbackLocaleSelector);
  }

  @injectable
  InitializeAppUseCase getAppInitializerUseCase(
    AnalyticsService analyticsService,
    CrashlyticsService crashlyticsService,
    SQLiteDb appDatabase,
  ) {
    return InitializeAppUseCase(
      crashlyticsService,
      analyticsService,
      appDatabase,
    );
  }

  @injectable
  InitializeSessionUseCase getInitializeSessionUseCase(
    GetAuthDataUseCase getAuthDataUseCase,
  ) {
    return InitializeSessionUseCase(
      GetUserIdUseCaseImpl(getAuthDataUseCase),
      SetAnalyticsSessionDataUseCaseImpl(
        FirebaseAnalyticsService(FirebaseAnalytics.instance),
      ),
      SetCrashlyticsSessionDataUseCaseImpl(
        FirebaseCrashlyticsService(FirebaseCrashlytics.instance),
      ),
    );
  }

  @singleton
  AppRootBloc getAppRootBloc(
    AppLogger logger,
    WatchAuthStateUseCase watchAuthState,
    WatchLocaleUseCase watchLocale,
    WatchThemeModeUseCase watchThemeMode,
    GetEffectiveLocaleUseCase getEffectiveLocale,
    GetEffectiveThemeModeUseCase getEffectiveThemeMode,
    InitializeAppUseCase initializeApp,
    InitializeSessionUseCase initializeSession,
  ) {
    return AppRootBloc(
      logger,
      watchAuthState,
      watchLocale,
      watchThemeMode,
      getEffectiveLocale,
      getEffectiveThemeMode,
      initializeApp,
      initializeSession,
    );
  }

  @singleton
  NavRouter getAppRouter(
    GlobalKey<NavigatorState> navigatorKey,
    IsAuthedUseCase isAuthedUseCase,
  ) {
    return NavRouterFactory().create(
      navigatorKey: navigatorKey,
      initialRoute: AppRoute.ROOT.routeInfo,
      routes: getAppRouteDefs(isAuthedUseCase),
      guards: [RouterLogger()],
    );
  }
}

FutureOr<dynamic> disposeSettingsRepository(SettingsRepository repository) {
  repository.dispose();
}

FutureOr<dynamic> disposeAppDatabase(SQLiteDb database) {
  database.dispose();
}

FutureOr<dynamic> disposeNetClient(NetClient client) {
  client.close();
}
