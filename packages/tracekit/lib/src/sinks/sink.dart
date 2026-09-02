import 'dart:async';

import '../models/log_record.dart';
import '../models/trace_level.dart';
import '../formatters/formatter.dart';

/// Destination that receives formatted log output.
abstract class TraceSink {
  /// Minimum level this sink accepts.
  TraceLevel get minLevel;

  /// Formatter used when [write] receives a [LogRecord].
  TraceFormatter get formatter;

  /// Writes [record] to this sink. Implementations must not throw.
  void write(LogRecord record);

  /// Flushes buffered output, when supported.
  Future<void> flush() async {}

  /// Releases resources held by this sink.
  Future<void> dispose() async {}
}
