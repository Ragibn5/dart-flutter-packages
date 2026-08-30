import 'package:flutter/widgets.dart';
import 'package:rover/src/go_route/go_route_app_router.dart';
import 'package:rover/src/models/route_def.dart';
import 'package:rover/src/models/route_info.dart';
import 'package:rover/src/rover.dart';
import 'package:rover/src/services/route_guard.dart';

class RoverFactory {
  Rover create({
    required GlobalKey<NavigatorState> navigatorKey,
    required RouteInfo initialRoute,
    required List<RouteDef> routes,
    List<RouteGuard> guards = const [],
  }) {
    return GoRouteAppRouter(
      navigatorKey: navigatorKey,
      initialRoute: initialRoute,
      routes: routes,
      guards: guards,
    );
  }
}
