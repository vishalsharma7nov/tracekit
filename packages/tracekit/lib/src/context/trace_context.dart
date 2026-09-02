import 'dart:async';

/// Zone-based mapped diagnostic context (MDC) for structured logging.
class TraceContext {
  TraceContext._();

  static final Object _contextKey = Object();

  /// Returns the current context map from the active zone.
  static Map<String, Object?> get current {
    final value = Zone.current[_contextKey];
    if (value is Map<String, Object?>) {
      return Map.unmodifiable(value);
    }
    return const {};
  }

  /// Runs [action] with additional [context] merged into the zone.
  static T runWithContext<T>(
    Map<String, Object?> context,
    T Function() action,
  ) {
    final merged = {...current, ...context};
    return runZoned(action, zoneValues: {_contextKey: merged});
  }

  /// Runs [action] in a zone that replaces the entire context map.
  static T runWithContextMap<T>(
    Map<String, Object?> context,
    T Function() action,
  ) {
    return runZoned(action, zoneValues: {_contextKey: Map.of(context)});
  }
}
