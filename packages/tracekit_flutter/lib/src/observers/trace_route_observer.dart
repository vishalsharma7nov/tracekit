import 'package:flutter/material.dart';
import 'package:tracekit/tracekit.dart';

/// Logs Flutter navigation events via [NavigatorObserver].
class TraceRouteObserver extends NavigatorObserver {
  /// Creates a [TraceRouteObserver].
  TraceRouteObserver({TraceLogger? logger})
      : _logger = logger ?? TraceKit.logger;

  final TraceLogger _logger;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _logRoute('push', route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _logRoute('pop', route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _logRoute('replace', newRoute);
    }
  }

  void _logRoute(String action, Route<dynamic> route) {
    _logger.info(
      'Navigation $action',
      context: {
        'route': route.settings.name ?? route.runtimeType.toString(),
        'arguments': route.settings.arguments?.toString(),
      },
    );
  }
}
