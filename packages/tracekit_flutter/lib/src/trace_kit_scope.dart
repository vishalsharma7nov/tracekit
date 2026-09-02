import 'package:flutter/widgets.dart';
import 'package:tracekit/tracekit.dart';

/// Provides [TraceLogger] via the widget tree.
class TraceKitScope extends InheritedWidget {
  /// Creates a [TraceKitScope].
  const TraceKitScope({
    required this.logger,
    required super.child,
    super.key,
  });

  /// Logger available to descendants.
  final TraceLogger logger;

  /// Returns the nearest [TraceLogger], falling back to [TraceKit.logger].
  static TraceLogger of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<TraceKitScope>();
    return scope?.logger ?? TraceKit.logger;
  }

  @override
  bool updateShouldNotify(TraceKitScope oldWidget) =>
      oldWidget.logger != logger;
}
