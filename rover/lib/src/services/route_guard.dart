import 'package:flutter/widgets.dart';
import 'package:rover/src/models/guard_result.dart';
import 'package:rover/src/models/route_context.dart';

abstract interface class RouteGuard {
  Future<GuardResult> onNavigationRequest(
    BuildContext context,
    RouteContext current,
    RouteContext next,
  );
}
