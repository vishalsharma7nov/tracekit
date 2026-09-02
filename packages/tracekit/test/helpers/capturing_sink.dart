import 'package:tracekit/tracekit.dart';

/// Test sink that captures all written [LogRecord]s.
class CapturingSink extends TraceSink {
  CapturingSink({
    this.minLevel = TraceLevel.trace,
    TraceFormatter? formatter,
  }) : formatter = formatter ?? const PlainTextFormatter();

  @override
  final TraceLevel minLevel;

  @override
  final TraceFormatter formatter;

  final List<LogRecord> records = [];

  @override
  void write(LogRecord record) => records.add(record);
}
