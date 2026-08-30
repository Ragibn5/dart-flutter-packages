import 'package:app_logger/app_logger.dart';
import 'package:app_template/features/app/infrastructure/router/guards/router_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rover/rover.dart';

class _FakeBuildContext extends Fake implements BuildContext {}

class _MockAppLogger extends Mock implements AppLogger {}

void main() {
  late _MockAppLogger mockAppLogger;

  setUp(() {
    mockAppLogger = _MockAppLogger();

    when(
      () => mockAppLogger.logDebug(
        tag: any(named: 'tag'),
        message: any(named: 'message'),
        extras: any(named: 'extras'),
      ),
    ).thenAnswer((_) => {});
  });

  test('Should log and return ContinueNavigation', () async {
    final sut = RouterLogger(mockAppLogger);
    final context = _FakeBuildContext();
    const current = RouteContext(info: RouteInfo('current', '/current'));
    const next = RouteContext(info: RouteInfo('next', '/next'));

    final result = await sut.onNavigationRequest(context, current, next);

    expect(result, isA<ContinueNavigation>());

    verify(
      () => mockAppLogger.logInfo(
        tag: '$RouterLogger',
        message: 'Routing: /current -> /next',
        extras: any(named: 'extras'),
      ),
    );
  });
}
