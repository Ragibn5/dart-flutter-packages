import 'package:flutter/material.dart';
import 'package:rover/rover.dart';

class TestGuard implements RouteGuard {
  @override
  Future<GuardResult> onNavigationRequest(
    BuildContext context,
    RouteContext current,
    RouteContext next,
  ) async => ContinueNavigation();
}

class TestBlockGuard implements RouteGuard {
  @override
  Future<GuardResult> onNavigationRequest(
    BuildContext context,
    RouteContext current,
    RouteContext next,
  ) async => BlockNavigation();
}

class TestRedirectGuard implements RouteGuard {
  @override
  Future<GuardResult> onNavigationRequest(
    BuildContext context,
    RouteContext current,
    RouteContext next,
  ) async => RedirectNavigation(
    const RouteContext(info: RouteInfo('login', '/login')),
  );
}
