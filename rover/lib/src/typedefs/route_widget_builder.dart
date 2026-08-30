import 'package:flutter/widgets.dart';
import 'package:rover/src/models/route_context.dart';
import 'package:rover/src/rover.dart';

typedef RouteWidgetBuilder =
    Widget Function(
      BuildContext context,
      Rover router,
      RouteContext routeContext,
    );
