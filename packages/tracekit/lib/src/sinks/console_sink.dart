import '../models/log_record.dart';
import '../models/trace_level.dart';
import '../formatters/formatter.dart';
import '../formatters/pretty_formatter.dart';
import '../formatters/json_formatter.dart';
import 'console_writer.dart';
import 'console_writer_stub.dart'
    if (dart.library.io) 'console_writer_io.dart'
    if (dart.library.html) 'console_writer_web.dart';
import 'sink.dart';

/// Writes formatted logs to the platform console via stdout/stderr or web console.
class ConsoleSink extends TraceSink {
  /// Creates a [ConsoleSink].
  ConsoleSink({
    required this.formatter,
    this.minLevel = TraceLevel.trace,
    ConsoleWriter? writer,
  }) : _writer = writer ?? createConsoleWriter();

  /// Pretty console sink for development.
  factory ConsoleSink.pretty({TraceLevel minLevel = TraceLevel.trace}) {
    return ConsoleSink(
      formatter: const PrettyFormatter(),
      minLevel: minLevel,
    );
  }

  /// JSON Lines console sink for structured output.
  factory ConsoleSink.json({TraceLevel minLevel = TraceLevel.trace}) {
    return ConsoleSink(
      formatter: const JsonFormatter(),
      minLevel: minLevel,
    );
  }

  @override
  final TraceFormatter formatter;

  @override
  final TraceLevel minLevel;

  final ConsoleWriter _writer;

  @override
  void write(LogRecord record) {
    try {
      final line = formatter.format(record);
      if (record.level.value >= TraceLevel.error.value) {
        _writer.writeError(line);
      } else {
        _writer.write(line);
      }
    } on Object {
      // Never crash the app due to logging failures.
    }
  }
}
