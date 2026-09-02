import '../models/log_record.dart';
import '../models/trace_level.dart';
import '../formatters/formatter.dart';
import 'sink.dart';

/// Routes records to different sinks based on tag/category.
class RoutingSink extends TraceSink {
  /// Creates a [RoutingSink].
  RoutingSink({
    required this.defaultSink,
    this.routes = const {},
  });

  /// Sink used when no route matches.
  final TraceSink defaultSink;

  /// Tag → sink routing table.
  final Map<String, TraceSink> routes;

  @override
  TraceLevel get minLevel => defaultSink.minLevel;

  @override
  TraceFormatter get formatter => defaultSink.formatter;

  @override
  void write(LogRecord record) {
    final tag = record.tag;
    final sink = (tag != null ? routes[tag] : null) ?? defaultSink;
    sink.write(record);
  }

  @override
  Future<void> flush() async {
    await defaultSink.flush();
    for (final sink in routes.values) {
      await sink.flush();
    }
  }

  @override
  Future<void> dispose() async {
    await defaultSink.dispose();
    for (final sink in routes.values) {
      await sink.dispose();
    }
  }
}
