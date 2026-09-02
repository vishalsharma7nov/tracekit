import '../models/log_record.dart';
import '../models/trace_level.dart';
import '../formatters/formatter.dart';
import 'sink.dart';

/// Fan-out sink that delegates to multiple child sinks.
class CompositeSink extends TraceSink {
  /// Creates a [CompositeSink].
  CompositeSink(this.sinks);

  /// Child sinks.
  final List<TraceSink> sinks;

  @override
  TraceLevel get minLevel {
    if (sinks.isEmpty) {
      return TraceLevel.fatal;
    }
    return sinks
        .map((s) => s.minLevel)
        .reduce((a, b) => a.value < b.value ? a : b);
  }

  @override
  TraceFormatter get formatter => sinks.first.formatter;

  @override
  void write(LogRecord record) {
    for (final sink in sinks) {
      if (record.level.isAtLeast(sink.minLevel)) {
        try {
          sink.write(record);
        } on Object {
          // Continue to other sinks on failure.
        }
      }
    }
  }

  @override
  Future<void> flush() async {
    for (final sink in sinks) {
      await sink.flush();
    }
  }

  @override
  Future<void> dispose() async {
    for (final sink in sinks) {
      await sink.dispose();
    }
  }
}
