import 'package:app_logger/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:rover/rover.dart';

class RouterLogger implements RouteGuard {
  final AppLogger _logger;

  RouterLogger(this._logger);

  @override
  Future<GuardResult> onNavigationRequest(
    BuildContext context,
    RouteContext current,
    RouteContext next,
  ) async {
    _logger.logInfo(
      tag: '$RouterLogger',
      message: 'Routing: ${current.info.path} -> ${next.info.path}',
    );
    return ContinueNavigation();
  }
}
