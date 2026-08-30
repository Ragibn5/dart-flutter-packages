import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rover/rover.dart';
import 'package:rover/src/go_route/go_route_app_router.dart';

Widget _dummyBuilder(
  BuildContext context,
  Rover router,
  RouteContext routeContext,
) => const SizedBox.shrink();

void main() {
  group('GoRouteAppRouter', () {
    late GoRouteAppRouter sut;

    setUp(() {
      sut = GoRouteAppRouter(
        navigatorKey: GlobalKey<NavigatorState>(),
        initialRoute: const RouteInfo('root', '/'),
        routes: [
          const RouteDef(
            info: RouteInfo('home', '/home'),
            builder: _dummyBuilder,
          ),
        ],
      );
    });

    group('routerConfig', () {
      test('returns a RouterConfig', () {
        expect(sut.routerConfig, isA<RouterConfig<Object>>());
      });
    });
  });
}
