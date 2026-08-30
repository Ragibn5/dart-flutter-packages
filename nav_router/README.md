# nav_router

A lightweight, interface-first navigation router for Flutter built on top of [go_router], with
named-route navigation, typed route guards, and app code that never depends on a concrete routing
implementation.

## Installation

#### From pub.dev

Add this to your `pubspec.yaml`

```yaml
dependencies:
  nav_router: ^1.0.0
```

#### Or, From Git repo

```yaml
dependencies:
  nav_router:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: nav_router
      ref: nav_router-1.0.0
```

## ✨ Features

- 🗺️ Declarative route registration.
- 🧭 Named navigation — push, replace, or go to a route with names.
- 🔐 Route guards (global and per-route) with continue / block / redirect outcomes.
- 📦 Pass relevant data to routes with path/query params, and extras.
- 🔗 Deep link support — incoming URLs and platform deep links are automatically resolved.

## 🚀 Get started

The usual minimal flow is:

- Create the router.
- Register the routes.
- Plug it into `MaterialApp.router` (or Cupertino).

For example,

```dart
import 'package:flutter/material.dart';
import 'package:nav_router/nav_router.dart';

void main() {
  // 1. Create the router.
  final router = NavRouterFactory().create(
    navigatorKey: GlobalKey<NavigatorState>(),
    initialRoute: const RouteInfo('home', '/'),
    routes: [
      // 2. Register the routes.
      RouteDef(
        info: const RouteInfo('home', '/'),
        builder: (context, router, routeContext) => const HomeScreen(),
      ),
      RouteDef(
        info: const RouteInfo('profile', '/profile/:name'),
        builder: (context, router, routeContext) =>
            ProfileScreen(
              name: routeContext.pathParameters['name'] ?? 'guest',
            ),
      ),
    ],
  );

  runApp(
    MaterialApp.router(
      // 3. Plug it into `MaterialApp.router` (or Cupertino)
      routerConfig: router.routerConfig,
    ),
  );
}
```

### 🧭 Navigating

Once you have a `NavRouter`, navigate from anywhere it is reachable:

```dart
void main() async {
  // ...

  // Push a route
  router.pushWithName('profile', pathParameters: {'name': 'alice'});

  // Replace the current route
  router.replaceWithName('profile', pathParameters: {'name': 'bob'});

  // Imperative navigate
  router.navigateTo('home');

  // Navigate back
  router.canPopTopRoute(); // -> Bool
  router.popTopRoute(); // Optionally with a result: popTopRoute('done');
  router.popUntilRoute((route) => route.info.name == 'home'); // Pops the top page until the condition is met.

  // Inspect the current route
  final RouteContext current = router.currentRoute;
}
```

- `pushWithName` — pushes a route onto the stack and returns a `Future<T?>` for its result.
- `replaceWithName` — replaces the current location with the target route.
- `navigateTo` — imperatively changes the current location without pushing if it can.
- `popTopRoute` / `canPopTopRoute` / `popUntilRoute` — handle back navigation.

> The `name` here is the name defined while declaring the corresponding route.
> We deliberately do not support path based navigation through the `NavRouter` interface because of ambiguity.

### 🔐 Route guards

Guards let you control navigation before it completes. Pass global guards to `create`, and per-route guards in the `RouteDef`. Per-route guards run after global guards.

Each guard returns a `GuardResult`:

- `ContinueNavigation` — allow the navigation.
- `BlockNavigation` — cancel it.
- `RedirectNavigation` — cancel and redirect to another route.

```dart
class AuthGuard implements RouteGuard {
  @override
  Future<GuardResult> onNavigationRequest(BuildContext context,
      RouteContext current,
      RouteContext next,) async {
    final isLoggedIn = await authService.isLoggedIn();
    return isLoggedIn
        ? ContinueNavigation()
        : RedirectNavigation(
      const RouteContext(info: RouteInfo('login', '/login')),
    );
  }
}

void main() {
  final router = NavRouterFactory().create(
    navigatorKey: GlobalKey<NavigatorState>(),
    initialRoute: const RouteInfo('home', '/'),
    guards: [AuthGuard()],
    routes: [
      RouteDef(
        info: const RouteInfo('dashboard', '/dashboard'),
        guards: [ManagerOnlyGuard()],
        builder: (context, router, routeContext) => const DashboardScreen(),
      ),
    ],
  );
}
```

### 📦 Route data

Each `RouteDef` pairs a `RouteInfo` (declarative `name` + `path`) with a `RouteWidgetBuilder`. The builder receives the `BuildContext`, the `NavRouter`, and a `RouteContext` holding the resolved parameters for the current location:

- `pathParameters` — values extracted from the path, e.g. `name` in `/profile/:name`.
- `queryParameters` — values from the query string.
- `extra` — arbitrary data passed during navigation.

## 📝 Example

See the [example](example/example.dart) for a complete demonstration.

[go_router]: https://pub.dev/packages/go_router