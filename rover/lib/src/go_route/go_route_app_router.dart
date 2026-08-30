import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:rover/src/models/guard_result.dart';
import 'package:rover/src/models/route_context.dart';
import 'package:rover/src/models/route_def.dart';
import 'package:rover/src/models/route_info.dart';
import 'package:rover/src/rover.dart';
import 'package:rover/src/services/route_guard.dart';

class GoRouteAppRouter implements Rover {
  final GlobalKey<NavigatorState> _navigatorKey;
  final RouteInfo _initialRoute;
  final List<RouteDef> _routes;
  final List<RouteGuard> _guards;

  late final GoRouter _router = GoRouter(
    navigatorKey: _navigatorKey,
    initialLocation: _initialRoute.path,
    onEnter: _handleGuards,
    routes: _routes
        .map(
          (r) => GoRoute(
            name: r.info.name,
            path: r.info.path,
            builder: (context, state) => r.builder(
              context,
              this,
              RouteContext(
                info: r.info,
                pathParameters: state.pathParameters,
                queryParameters: state.uri.queryParameters,
                extra: state.extra,
              ),
            ),
          ),
        )
        .toList(),
  );

  GoRouteAppRouter({
    required GlobalKey<NavigatorState> navigatorKey,
    required RouteInfo initialRoute,
    required List<RouteDef> routes,
    List<RouteGuard> guards = const [],
  }) : _navigatorKey = navigatorKey,
       _initialRoute = initialRoute,
       _routes = routes,
       _guards = guards;

  @override
  RouterConfig<Object> get routerConfig => _router;

  @override
  RouteContext get currentRoute {
    final state = _router.state;
    return RouteContext(
      info: RouteInfo(state.name ?? '', state.matchedLocation),
      pathParameters: state.pathParameters,
      queryParameters: state.uri.queryParameters,
      extra: state.extra,
    );
  }

  @override
  Future<T?> pushWithName<T extends Object?>(
    String routeName, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Object? extra,
  }) => _router.pushNamed<T>(
    routeName,
    pathParameters: pathParameters,
    queryParameters: queryParameters,
    extra: extra,
  );

  @override
  Future<T?> replaceWithName<T extends Object?>(
    String routeName, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Object? extra,
  }) => _router.replaceNamed<T>(
    routeName,
    pathParameters: pathParameters,
    queryParameters: queryParameters,
    extra: extra,
  );

  @override
  void navigateTo(
    String routeName, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Object? extra,
  }) => _router.goNamed(
    routeName,
    pathParameters: pathParameters,
    queryParameters: queryParameters,
    extra: extra,
  );

  @override
  bool canPopTopRoute() => _router.canPop();

  @override
  void popTopRoute<T extends Object?>([T? result]) => _router.pop<T>(result);

  @override
  void popUntilRoute(bool Function(RouteContext) predicate) {
    while (_router.canPop()) {
      if (predicate(currentRoute)) return;
      _router.pop();
    }
  }

  Future<OnEnterResult> _handleGuards(
    BuildContext context,
    GoRouterState currentState,
    GoRouterState nextState,
    GoRouter router,
  ) async {
    final current = RouteContext(
      info: RouteInfo(currentState.name ?? '', currentState.matchedLocation),
      pathParameters: currentState.pathParameters,
      queryParameters: currentState.uri.queryParameters,
      extra: currentState.extra,
    );
    final next = RouteContext(
      info: RouteInfo(nextState.name ?? '', nextState.matchedLocation),
      pathParameters: nextState.pathParameters,
      queryParameters: nextState.uri.queryParameters,
      extra: nextState.extra,
    );

    final routeDef = _routes.firstWhere(
      (r) => r.info.name == nextState.name || r.info.path == nextState.path,
    );
    final allGuards = [..._guards, ...routeDef.guards];

    for (final guard in allGuards) {
      final result = await guard.onNavigationRequest(context, current, next);
      switch (result) {
        case BlockNavigation():
          return const Block.stop();
        case RedirectNavigation():
          return Block.then(
            () => router.goNamed(
              result.redirectRoute.info.name,
              pathParameters: result.redirectRoute.pathParameters,
              queryParameters: result.redirectRoute.queryParameters,
              extra: result.redirectRoute.extra,
            ),
          );
        case ContinueNavigation():
          break;
      }
    }

    return const Allow();
  }
}
