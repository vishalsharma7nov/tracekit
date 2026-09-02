import '../models/log_record.dart';
import '../models/trace_level.dart';
import 'filter.dart';

/// Filters records below a minimum [TraceLevel].
class LevelFilter implements TraceFilter {
  /// Creates a [LevelFilter].
  const LevelFilter(this.minLevel);

  /// Minimum level to pass through.
  final TraceLevel minLevel;

  @override
  bool shouldLog(LogRecord record) => record.level.isAtLeast(minLevel);
}
