/// Severity levels for log records, ordered from lowest to highest priority.
enum TraceLevel {
  /// Fine-grained diagnostic information.
  trace(0, 'TRACE'),

  /// Debug information useful during development.
  debug(1, 'DEBUG'),

  /// General informational messages.
  info(2, 'INFO'),

  /// Potentially harmful situations.
  warn(3, 'WARN'),

  /// Error events that might still allow the app to continue.
  error(4, 'ERROR'),

  /// Very severe error events that will presumably lead to app abort.
  fatal(5, 'FATAL');

  /// Creates a [TraceLevel] with [value] and [label].
  const TraceLevel(this.value, this.label);

  /// Numeric priority used for filtering (higher = more severe).
  final int value;

  /// Short uppercase label for formatters.
  final String label;

  /// Returns true when [other] meets or exceeds this level's severity.
  bool isAtLeast(TraceLevel other) => value >= other.value;
}
