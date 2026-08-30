import 'dart:io';
import 'dart:ui';

import 'package:app_template/features/app/application/use_cases/get_effective_locale_use_case.dart';
import 'package:app_template/features/app/domain/models/locale_components.dart';
import 'package:app_template/features/app/infrastructure/models/build_metadata.dart';
import 'package:net_client/net_client.dart';

class MetadataHeaderKeys {
  static const APP_SCOPE = 'app-scope';
  static const APP_PLATFORM = 'app-platform';
  static const APP_PLATFORM_VERSION = 'app-platform-version';
  static const APP_RUNTIME = 'app-runtime';
  static const APP_RUNTIME_VERSION = 'app-runtime-version';
  static const APP_PACKAGE = 'app-package';
  static const APP_FLAVOR = 'app-flavor';
  static const APP_VERSION_NAME = 'app-version-name';
  static const APP_VERSION_CODE = 'app-version-code';
}

class MetadataAdderInterceptor extends NetClientInterceptor {
  final BuildMetadata _buildMetadata;
  final GetEffectiveLocaleUseCase _getEffectiveLocale;

  MetadataAdderInterceptor(this._buildMetadata, this._getEffectiveLocale);

  @override
  Future<RequestInterceptorResult> onRequest(RequestSpec request) async {
    final locale = await _getEffectiveLocale();
    return ContinueWithRequest(
      request.copyWith(
        headers: request.headers
          ..addAll(_buildLocaleHeaders(locale))
          ..addAll(_buildUserAgentHeaders(_buildMetadata))
          ..addAll(_buildAppMetadataHeaders(_buildMetadata)),
      ),
    );
  }

  Map<String, String> _buildLocaleHeaders(LocaleComponents locale) {
    final platformLocale = Locale.fromSubtags(
      languageCode: locale.languageCode,
      scriptCode: locale.scriptCode,
      countryCode: locale.countryCode,
    );

    return {HttpHeaders.acceptLanguageHeader: platformLocale.toLanguageTag()};
  }

  Map<String, String> _buildUserAgentHeaders(BuildMetadata metadata) {
    final product = metadata.packageName; // e.g., 'com.example.app'
    final version = metadata.versionName; // e.g., '1.2.3'

    // Build the comment section
    final commentParts = <String>[
      metadata.platform, // 'Android' / 'iOS'
      metadata.runtime, // 'Flutter'
      metadata.flavor, // 'dev' / 'prod'
    ];

    return {
      HttpHeaders.userAgentHeader:
          '$product/$version (${commentParts.join('; ')})',
    };
  }

  Map<String, String> _buildAppMetadataHeaders(BuildMetadata metadata) {
    return {
      MetadataHeaderKeys.APP_SCOPE: metadata.scope,
      MetadataHeaderKeys.APP_PLATFORM: metadata.platform,
      MetadataHeaderKeys.APP_PLATFORM_VERSION: metadata.platformVersion,
      MetadataHeaderKeys.APP_RUNTIME: metadata.runtime,
      MetadataHeaderKeys.APP_RUNTIME_VERSION: metadata.runtimeVersion,
      MetadataHeaderKeys.APP_PACKAGE: metadata.packageName,
      MetadataHeaderKeys.APP_FLAVOR: metadata.flavor,
      MetadataHeaderKeys.APP_VERSION_NAME: metadata.versionName,
      MetadataHeaderKeys.APP_VERSION_CODE: metadata.versionCode,
    };
  }
}
