import 'package:app_template/features/app/infrastructure/router/guards/router_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rover/rover.dart';

class _FakeBuildContext extends Fake implements BuildContext {}

void main() {
  test('Should return ContinueNavigation and not throw', () async {
    final sut = RouterLogger();
    final context = _FakeBuildContext();
    const current = RouteContext(info: RouteInfo('current', '/current'));
    const next = RouteContext(info: RouteInfo('next', '/next'));

    final result = await sut.onNavigationRequest(context, current, next);

    expect(result, isA<ContinueNavigation>());
  });
}
