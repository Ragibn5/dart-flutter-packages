import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rover/rover.dart';
import 'package:rover/src/auto_route/auto_route_app_router.dart';

import '../test_helpers.dart';

class _MockNavigationResolver extends Mock implements NavigationResolver {}

class _MockStackRouter extends Mock implements StackRouter {}

class _MockRouteData extends Mock implements RouteData {}

class _MockRouteMatch extends Mock implements RouteMatch {}

class _MockParameters extends Mock implements Parameters {}

class _MockBuildContext extends Mock implements BuildContext {}

Widget _dummyBuilder(
  BuildContext context,
  Rover router,
  RouteContext routeContext,
) => const SizedBox.shrink();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(_MockStackRouter());
    registerFallbackValue(
      NamedRoute('fallback', params: {}, queryParams: {}, args: null),
    );
  });

  group('AutoRouteAppRouter', () {
    late AutoRouteAppRouter sut;

    setUp(() {
      sut = AutoRouteAppRouter(
        navigatorKey: GlobalKey<NavigatorState>(),
        initialRoute: const RouteInfo('root', '/'),
        routes: [
          RouteDef(
            info: const RouteInfo('home', '/home'),
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

    group('guards chain', () {
      late _MockNavigationResolver resolver;
      late _MockStackRouter router;
      late _MockRouteData currentRouteData;
      late _MockRouteMatch currentRouteMatch;
      late _MockRouteMatch nextRouteMatch;
      late _MockParameters params;
      late _MockBuildContext context;

      setUp(() {
        resolver = _MockNavigationResolver();
        router = _MockStackRouter();
        currentRouteData = _MockRouteData();
        currentRouteMatch = _MockRouteMatch();
        nextRouteMatch = _MockRouteMatch();
        params = _MockParameters();
        context = _MockBuildContext();

        // RouteData mocks
        when(() => currentRouteData.name).thenReturn('home');
        when(() => currentRouteData.path).thenReturn('/home');
        when(() => currentRouteData.params).thenReturn(params);
        when(() => currentRouteData.queryParams).thenReturn(params);
        when(() => currentRouteData.args).thenReturn(null);
        when(() => currentRouteData.route).thenReturn(currentRouteMatch);
        when(() => router.current).thenReturn(currentRouteData);

        // RouteMatch mocks (for current route)
        when(() => currentRouteMatch.params).thenReturn(params);
        when(() => currentRouteMatch.queryParams).thenReturn(params);
        when(() => currentRouteMatch.args).thenReturn(null);

        // RouteMatch mocks (for next/resolver route)
        when(() => nextRouteMatch.name).thenReturn('home');
        when(() => nextRouteMatch.path).thenReturn('/home');
        when(() => nextRouteMatch.params).thenReturn(params);
        when(() => nextRouteMatch.queryParams).thenReturn(params);
        when(() => nextRouteMatch.args).thenReturn(null);

        // Resolver mocks — resolver.route returns RouteMatch
        when(() => resolver.route).thenReturn(nextRouteMatch);
        when(() => resolver.routeName).thenReturn('home');
        when(() => resolver.context).thenReturn(context);

        // Parameters mock
        when(() => params.rawMap).thenReturn(<String, dynamic>{});
      });

      test('calls resolver.next() when guard returns Continue', () async {
        sut = AutoRouteAppRouter(
          navigatorKey: GlobalKey<NavigatorState>(),
          initialRoute: const RouteInfo('root', '/'),
          routes: [
            RouteDef(
              info: const RouteInfo('home', '/home'),
              builder: _dummyBuilder,
              guards: [TestGuard()],
            ),
          ],
        );

        sut.guards.first.onNavigation(resolver, router);
        await Future<void>.delayed(Duration.zero);

        verify(() => resolver.next()).called(1);
      });

      test('calls resolver.next(false) when guard returns Block', () async {
        sut = AutoRouteAppRouter(
          navigatorKey: GlobalKey<NavigatorState>(),
          initialRoute: const RouteInfo('root', '/'),
          routes: [
            RouteDef(
              info: const RouteInfo('home', '/home'),
              builder: _dummyBuilder,
              guards: [TestBlockGuard()],
            ),
          ],
        );

        sut.guards.first.onNavigation(resolver, router);
        await Future<void>.delayed(Duration.zero);

        verify(() => resolver.next(false)).called(1);
      });

      test(
        'calls resolver.next(false) and push when guard returns Redirect',
        () async {
          sut = AutoRouteAppRouter(
            navigatorKey: GlobalKey<NavigatorState>(),
            initialRoute: const RouteInfo('root', '/'),
            routes: [
              RouteDef(
                info: const RouteInfo('home', '/home'),
                builder: _dummyBuilder,
                guards: [TestRedirectGuard()],
              ),
            ],
          );

          when(() => router.push(any())).thenAnswer((_) async => null);

          sut.guards.first.onNavigation(resolver, router);
          await Future<void>.delayed(Duration.zero);

          verify(() => resolver.next(false)).called(1);
          verify(() => router.push(any())).called(1);
        },
      );
    });
  });
}
