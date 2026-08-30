import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rover/rover.dart';

Widget _dummyBuilder(
  BuildContext context,
  Rover router,
  RouteContext routeContext,
) => const SizedBox.shrink();

void main() {
  group('RouteDef', () {
    test('stores info, builder, and guards', () {
      const info = RouteInfo('home', '/home');
      const def = RouteDef(info: info, builder: _dummyBuilder);
      expect(def.info, info);
      expect(def.builder, _dummyBuilder);
      expect(def.guards, isEmpty);
    });

    test('stores guards', () {
      final guard = _TestGuard();
      const info = RouteInfo('home', '/home');
      final def = RouteDef(info: info, builder: _dummyBuilder, guards: [guard]);
      expect(def.guards, [guard]);
    });
  });
}

class _TestGuard implements RouteGuard {
  @override
  Future<GuardResult> onNavigationRequest(
    BuildContext context,
    RouteContext current,
    RouteContext next,
  ) async => ContinueNavigation();
}
