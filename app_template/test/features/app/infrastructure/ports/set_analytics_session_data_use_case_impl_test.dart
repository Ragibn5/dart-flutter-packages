// ignore_for_file: lines_longer_than_80_chars

import 'package:analykit/analykit.dart';
import 'package:app_template/features/app/infrastructure/ports/set_analytics_session_data_use_case_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  late _MockAnalyticsService mockAnalyticsService;

  late SetAnalyticsSessionDataUseCaseImpl sut;

  setUp(() {
    mockAnalyticsService = _MockAnalyticsService();

    sut = SetAnalyticsSessionDataUseCaseImpl(mockAnalyticsService);

    when(
      () => mockAnalyticsService.setSessionData(
        any(),
        collectionEnabled: any(named: 'collectionEnabled'),
      ),
    ).thenAnswer((_) async {});
  });

  test('Should delegate to AnalyticsService with correct arguments', () async {
    await sut('test-user', collectionEnabled: true);

    verify(
      () => mockAnalyticsService.setSessionData(
        'test-user',
        collectionEnabled: true,
      ),
    ).called(1);
  });
}
