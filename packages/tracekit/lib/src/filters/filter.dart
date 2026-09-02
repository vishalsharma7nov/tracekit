import '../models/log_record.dart';

/// Determines whether a [LogRecord] proceeds through the pipeline.
abstract class TraceFilter {
  /// Returns true when [record] should be emitted.
  bool shouldLog(LogRecord record);
}

/// Function-based filter for custom predicates.
class CallbackFilter implements TraceFilter {
  /// Creates a [CallbackFilter].
  const CallbackFilter(this.predicate);

  /// Custom filter predicate.
  final bool Function(LogRecord record) predicate;

  @override
  bool shouldLog(LogRecord record) => predicate(record);
}
