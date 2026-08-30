// ignore_for_file: lines_longer_than_80_chars

import 'package:app_template/features/app/infrastructure/ports/set_crashlytics_session_data_use_case_impl.dart';
import 'package:crashlykit/crashlykit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCrashlyticsService extends Mock implements CrashlyticsService {}

void main() {
  late _MockCrashlyticsService mockCrashlyticsService;

  late SetCrashlyticsSessionDataUseCaseImpl sut;

  setUp(() {
    mockCrashlyticsService = _MockCrashlyticsService();

    sut = SetCrashlyticsSessionDataUseCaseImpl(mockCrashlyticsService);

    when(
      () => mockCrashlyticsService.setSessionData(
        any(),
        collectionEnabled: any(named: 'collectionEnabled'),
      ),
    ).thenAnswer((_) async {});
  });

  test(
    'Should delegate to CrashlyticsService with correct arguments',
    () async {
      await sut('test-user', collectionEnabled: true);

      verify(
        () => mockCrashlyticsService.setSessionData(
          'test-user',
          collectionEnabled: true,
        ),
      ).called(1);
    },
  );
}
