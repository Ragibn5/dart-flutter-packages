import 'package:flutter/material.dart';
import 'package:rover/rover.dart';

void main() {
  final navKey = GlobalKey<NavigatorState>();

  final router = RoverFactory().create(
    navigatorKey: navKey,
    initialRoute: const RouteInfo('home', '/'),
    routes: [
      RouteDef(
        info: const RouteInfo('home', '/'),
        builder: (context, router, routeContext) => HomePage(
          onProfileNavRequest: (name) =>
              /// A page exposing a nav request, as callback, and
              /// we are navigating to appropriate page externally.
              /// This decouples screens, or features, from each other.
              router.pushWithName('profile', pathParameters: {'name': name}),
        ),
      ),
      RouteDef(
        info: const RouteInfo('profile', '/profile/:name'),
        builder: (context, router, routeContext) =>
            ProfilePage(name: routeContext.pathParameters['name'] ?? 'guest'),
      ),
    ],
  );

  runApp(MaterialApp.router(routerConfig: router.routerConfig));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onProfileNavRequest});

  final ValueChanged<String> onProfileNavRequest;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => onProfileNavRequest('alice'),
              child: const Text('Go to profile'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(child: Text(name, style: const TextStyle(fontSize: 20))),
    );
  }
}
