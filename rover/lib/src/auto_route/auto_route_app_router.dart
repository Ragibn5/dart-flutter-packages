import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:rover/src/models/guard_result.dart';
import 'package:rover/src/models/route_context.dart';
import 'package:rover/src/models/route_def.dart';
import 'package:rover/src/models/route_info.dart';
import 'package:rover/src/rover.dart';
import 'package:rover/src/services/route_guard.dart';

@AutoRouterConfig()
class AutoRouteAppRouter extends RootStackRouter implements Rover {
  final List<RouteDef> _routes;
  final RouteInfo? _initialRoute;
  final List<RouteGuard> _guards;

  AutoRouteAppRouter({
    required GlobalKey<NavigatorState> navigatorKey,
    required RouteInfo initialRoute,
    required List<RouteDef> routes,
    List<RouteGuard> guards = const [],
  }) : _initialRoute = initialRoute,
       _routes = routes,
       _guards = guards,
       super(navigatorKey: navigatorKey);

  @override
  RouterConfig<Object> get routerConfig => super.config();

  @override
  RouteContext get currentRoute {
    final state = current;
    return RouteContext(
      info: RouteInfo(state.name, state.path),
      pathParameters: state.params.rawMap.map(
        (k, v) => MapEntry(k, v.toString()),
      ),
      queryParameters: state.queryParams.rawMap.map(
        (k, v) => MapEntry(k, v.toString()),
      ),
      extra: state.args,
    );
  }

  @override
  Future<T?> pushWithName<T extends Object?>(
    String routeName, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Object? extra,
  }) => push<T>(
    NamedRoute(
      routeName,
      params: pathParameters,
      queryParams: queryParameters,
      args: extra,
    ),
  );

  @override
  Future<T?> replaceWithName<T extends Object?>(
    String routeName, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Object? extra,
  }) => replace<T>(
    NamedRoute(
      routeName,
      params: pathParameters,
      queryParams: queryParameters,
      args: extra,
    ),
  );

  @override
  void navigateTo(
    String routeName, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Object? extra,
  }) => navigate(
    NamedRoute(
      routeName,
      params: pathParameters,
      queryParams: queryParameters,
      args: extra,
    ),
  );

  @override
  bool canPopTopRoute() => canPop();

  @override
  void popTopRoute<T extends Object?>([T? result]) => pop<T>(result);

  @override
  void popUntilRoute(bool Function(RouteContext) predicate) {
    while (canPop()) {
      if (predicate(currentRoute)) return;
      pop();
    }
  }

  @protected
  @override
  List<AutoRoute> get routes => _routes
      .map(
        (r) => NamedRouteDef(
          name: r.info.name,
          path: r.info.path,
          initial: r.info.path == _initialRoute?.path,
          builder: (c, d) => r.builder(
            c,
            this,
            RouteContext(
              info: r.info,
              pathParameters: d.params.rawMap.map(
                (k, v) => MapEntry(k, v.toString()),
              ),
              queryParameters: d.queryParams.rawMap.map(
                (k, v) => MapEntry(k, v.toString()),
              ),
              extra: d.args,
            ),
          ),
        ),
      )
      .toList();

  @protected
  @override
  List<AutoRouteGuard> get guards => [_GuardChain(_guards, _routes)];
}

class _GuardChain extends AutoRouteGuard {
  final List<RouteGuard> _guards;
  final List<RouteDef> _routes;

  _GuardChain(this._guards, this._routes);

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    _resolve(resolver, router);
  }

  Future<void> _resolve(NavigationResolver resolver, StackRouter router) async {
    final routeDef = _routes.firstWhere(
      (r) =>
          r.info.name == resolver.route.name ||
          r.info.path == resolver.route.path,
    );
    final allGuards = [..._guards, ...routeDef.guards];

    final current = RouteContext(
      info: RouteInfo(router.current.name, router.current.path),
      pathParameters: router.current.route.params.rawMap.map(
        (k, v) => MapEntry(k, v.toString()),
      ),
      queryParameters: router.current.route.queryParams.rawMap.map(
        (k, v) => MapEntry(k, v.toString()),
      ),
      extra: router.current.route.args,
    );
    final next = RouteContext(
      info: RouteInfo(resolver.routeName, resolver.route.path),
      pathParameters: resolver.route.params.rawMap.map(
        (k, v) => MapEntry(k, v.toString()),
      ),
      queryParameters: resolver.route.queryParams.rawMap.map(
        (k, v) => MapEntry(k, v.toString()),
      ),
      extra: resolver.route.args,
    );

    for (final guard in allGuards) {
      final result = await guard.onNavigationRequest(
        resolver.context,
        current,
        next,
      );
      switch (result) {
        case BlockNavigation():
          resolver.next(false);
          return;
        case RedirectNavigation():
          resolver.next(false);
          unawaited(
            router.push(
              NamedRoute(
                result.redirectRoute.info.name,
                params: result.redirectRoute.pathParameters,
                queryParams: result.redirectRoute.queryParameters,
                args: result.redirectRoute.extra,
              ),
            ),
          );
          return;
        case ContinueNavigation():
          break;
      }
    }

    resolver.next();
  }
}
