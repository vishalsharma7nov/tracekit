import '../models/log_record.dart';
import '../models/trace_level.dart';
import '../formatters/formatter.dart';
import '../formatters/plain_text_formatter.dart';
import 'sink.dart';

/// Discards all log output (useful for tests and disabled logging).
class NoOpSink extends TraceSink {
  /// Shared no-op instance.
  static final NoOpSink instance = NoOpSink._();

  NoOpSink._();

  @override
  final TraceLevel minLevel = TraceLevel.trace;

  @override
  final TraceFormatter formatter = const PlainTextFormatter();

  @override
  void write(LogRecord record) {}
}
