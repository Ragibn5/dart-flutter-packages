import 'package:rover/src/models/route_context.dart';

sealed class GuardResult {}

final class ContinueNavigation extends GuardResult {}

final class BlockNavigation extends GuardResult {}

final class RedirectNavigation extends GuardResult {
  final RouteContext redirectRoute;

  RedirectNavigation(this.redirectRoute);
}
