import '../models/log_record.dart';

/// Converts [LogRecord] instances to output strings.
abstract class TraceFormatter {
  /// Formats [record] as a string for sinks.
  String format(LogRecord record);
}
