import 'dart:async';

import 'package:app_template/features/app/domain/models/app_settings.dart';

abstract interface class SettingsRepository {
  /// Get the current app settings.
  Future<AppSettings> getCurrentSettings();

  /// Set current app settings.
  Future<void> setCurrentSettings(AppSettings settings);

  /// Watch app settings change.
  Stream<AppSettings> getSettingsStream();

  /// Release any resources held by this repository.
  FutureOr<void> dispose();
}
