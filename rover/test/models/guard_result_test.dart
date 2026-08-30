import 'package:flutter_test/flutter_test.dart';
import 'package:rover/rover.dart';

void main() {
  group('GuardResult', () {
    test('Continue is a GuardResult', () {
      expect(ContinueNavigation(), isA<GuardResult>());
    });

    test('Block is a GuardResult', () {
      expect(BlockNavigation(), isA<GuardResult>());
    });

    test('Redirect is a GuardResult', () {
      const redirectRoute = RouteContext(info: RouteInfo('test', '/test'));
      final result = RedirectNavigation(redirectRoute);
      expect(result, isA<GuardResult>());
      expect(result.redirectRoute, same(redirectRoute));
    });
  });
}
