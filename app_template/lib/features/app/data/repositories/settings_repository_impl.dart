import 'dart:async';

import 'package:app_template/features/app/data/models/settings_dto.dart';
import 'package:app_template/features/app/data/sources/settings_data_source.dart';
import 'package:app_template/features/app/domain/models/app_settings.dart';
import 'package:app_template/features/app/domain/repositories/settings_repository.dart';
import 'package:data_domain_converters/data_domain_converters.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final StreamController<AppSettings> _settingsStreamController;

  final DataDomainConverter<SettingsDTO, AppSettings> _settingsMapper;

  final SettingsDataSource _settingsDataSource;

  SettingsRepositoryImpl(
    this._settingsStreamController,
    this._settingsMapper,
    this._settingsDataSource,
  );

  @override
  Future<AppSettings> getCurrentSettings() async {
    final settingsDTO = await _settingsDataSource.getCurrentSettings();
    if (settingsDTO == null) {
      return const AppSettings();
    }

    return _settingsMapper.convertDataToDomain(settingsDTO);
  }

  @override
  Future<void> setCurrentSettings(AppSettings settings) async {
    // First add to stream to notify listeners
    _settingsStreamController.add(settings);

    // Then add to data source
    final settingsDTO = _settingsMapper.convertDomainToData(settings);
    return _settingsDataSource.setCurrentSettings(settingsDTO);
  }

  @override
  Stream<AppSettings> getSettingsStream() {
    return _settingsStreamController.stream;
  }

  @override
  void dispose() {
    _settingsStreamController.close();
  }
}
