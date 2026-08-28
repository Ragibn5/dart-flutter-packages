// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';

import 'package:app_template/features/app/data/models/settings_dto.dart';
import 'package:app_template/features/app/data/repositories/settings_repository_impl.dart';
import 'package:app_template/features/app/data/sources/settings_data_source.dart';
import 'package:app_template/features/app/domain/models/app_locale.dart';
import 'package:app_template/features/app/domain/models/app_settings.dart';
import 'package:app_template/features/app/domain/models/app_theme_mode.dart';
import 'package:data_domain_converters/data_domain_converters.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSettingsStreamController extends Mock
    implements StreamController<AppSettings> {}

class _MockSettingsConverter extends Mock
    implements DataDomainConverter<SettingsDTO, AppSettings> {}

class _MockSettingsDataSource extends Mock implements SettingsDataSource {}

void main() {
  final settingsDto = SettingsDTO(
    locale: AppLocale.EN.name,
    themeMode: AppThemeMode.LIGHT.name,
  );
  const settings = AppSettings(
    locale: AppLocale.EN,
    themeMode: AppThemeMode.LIGHT,
  );
  const settingsStream = Stream<AppSettings>.empty();

  late _MockSettingsStreamController mockSettingsStreamController;
  late _MockSettingsConverter mockSettingsConverter;
  late _MockSettingsDataSource mockSettingsDataSource;

  late SettingsRepositoryImpl sut;

  setUpAll(() {
    registerFallbackValue(settings);
    registerFallbackValue(settingsDto);
  });

  setUp(() {
    mockSettingsStreamController = _MockSettingsStreamController();
    mockSettingsConverter = _MockSettingsConverter();
    mockSettingsDataSource = _MockSettingsDataSource();

    sut = SettingsRepositoryImpl(
      mockSettingsStreamController,
      mockSettingsConverter,
      mockSettingsDataSource,
    );

    when(
      () => mockSettingsConverter.convertDataToDomain(settingsDto),
    ).thenReturn(settings);
    when(
      () => mockSettingsConverter.convertDomainToData(settings),
    ).thenReturn(settingsDto);
    when(() => mockSettingsStreamController.add(any())).thenAnswer((_) {});
    when(
      () => mockSettingsDataSource.getCurrentSettings(),
    ).thenAnswer((_) async => settingsDto);
    when(
      () => mockSettingsDataSource.setCurrentSettings(settingsDto),
    ).thenAnswer((_) async {});
    when(
      () => mockSettingsStreamController.stream,
    ).thenAnswer((_) => settingsStream);
    when(() => mockSettingsStreamController.close()).thenAnswer((_) async {});
  });

  test(
    '`getCurrentSettings` should return shell AppSettings if data source returned null',
    () async {
      when(
        () => mockSettingsDataSource.getCurrentSettings(),
      ).thenAnswer((_) async => null);

      final result = await sut.getCurrentSettings();
      expect(result, const AppSettings());
      verify(() => mockSettingsDataSource.getCurrentSettings()).called(1);
      verifyNever(() => mockSettingsConverter.convertDataToDomain(any()));
    },
  );

  test(
    '`getCurrentSettings` should return correct domain model if data source returned non-null',
    () async {
      final result = await sut.getCurrentSettings();

      expect(result.locale.name, settingsDto.locale);
      expect(result.themeMode.name, settingsDto.themeMode);
      verify(() => mockSettingsDataSource.getCurrentSettings()).called(1);
      verify(
        () => mockSettingsConverter.convertDataToDomain(settingsDto),
      ).called(1);
    },
  );

  test(
    '`setCurrentSettings` should add to stream, and call data source',
    () async {
      await sut.setCurrentSettings(settings);

      verify(() => mockSettingsStreamController.add(settings)).called(1);
      verify(
        () => mockSettingsDataSource.setCurrentSettings(settingsDto),
      ).called(1);
    },
  );

  test(
    'getSettingsStream` should return a stream from the stream controller',
    () async {
      final result = sut.getSettingsStream();

      expect(result, settingsStream);
    },
  );

  test('`dispose` should close the stream', () async {
    await sut.dispose();
    verify(() => mockSettingsStreamController.close()).called(1);
  });
}
