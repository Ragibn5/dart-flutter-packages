import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rover/rover.dart';

Widget _dummyBuilder(
  BuildContext context,
  Rover router,
  RouteContext routeContext,
) => const SizedBox.shrink();

void main() {
  group('RoverFactory', () {
    late RoverFactory sut;

    setUp(() {
      sut = RoverFactory();
    });

    test('create returns a Rover', () {
      final router = sut.create(
        navigatorKey: GlobalKey<NavigatorState>(),
        initialRoute: const RouteInfo('root', '/'),
        routes: [
          RouteDef(
            info: const RouteInfo('home', '/home'),
            builder: _dummyBuilder,
          ),
        ],
      );
      expect(router, isA<Rover>());
    });
  });
}
