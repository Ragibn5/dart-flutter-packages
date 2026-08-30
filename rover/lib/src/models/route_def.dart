import 'package:rover/src/models/route_info.dart';
import 'package:rover/src/services/route_guard.dart';
import 'package:rover/src/typedefs/route_widget_builder.dart';

class RouteDef {
  final RouteInfo info;
  final RouteWidgetBuilder builder;
  final List<RouteGuard> guards;

  const RouteDef({
    required this.info,
    required this.builder,
    this.guards = const [],
  });
}
