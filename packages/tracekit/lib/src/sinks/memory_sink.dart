import '../models/log_record.dart';
import '../models/trace_level.dart';
import '../formatters/formatter.dart';
import '../formatters/json_formatter.dart';
import 'sink.dart';

/// Ring-buffer sink that retains recent [LogRecord]s for in-app viewers.
class MemorySink extends TraceSink {
  /// Creates a [MemorySink].
  MemorySink({
    this.maxEntries = 500,
    this.minLevel = TraceLevel.trace,
    TraceFormatter? formatter,
  }) : formatter = formatter ?? const JsonFormatter();

  /// Maximum records retained (oldest dropped first).
  final int maxEntries;

  @override
  final TraceLevel minLevel;

  @override
  final TraceFormatter formatter;

  final List<LogRecord> _records = [];

  /// Unmodifiable view of retained records.
  List<LogRecord> get records => List.unmodifiable(_records);

  /// Clears all retained records.
  void clear() => _records.clear();

  @override
  void write(LogRecord record) {
    _records.add(record);
    while (_records.length > maxEntries) {
      _records.removeAt(0);
    }
  }
}
