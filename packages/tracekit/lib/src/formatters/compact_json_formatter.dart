import '../models/log_record.dart';
import 'formatter.dart';

/// Minimal single-line JSON without whitespace.
class CompactJsonFormatter implements TraceFormatter {
  /// Creates a [CompactJsonFormatter].
  const CompactJsonFormatter();

  @override
  String format(LogRecord record) {
    final map = record.toJson();
    return map.entries
        .where((e) => e.value != null)
        .map((e) => '"${e.key}":"${e.value}"')
        .join(',');
  }
}
