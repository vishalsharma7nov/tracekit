import '../models/trace_level.dart';
import '../caller/caller_info.dart';
import '../otel/otel_context.dart';

/// Immutable snapshot of a single log event flowing through the pipeline.
class LogRecord {
  /// Creates a [LogRecord].
  const LogRecord({
    required this.level,
    required this.message,
    required this.timestamp,
    this.tag,
    this.context = const {},
    this.error,
    this.stackTrace,
    this.caller,
    this.isolateName,
    this.otel,
  });

  /// Severity of this log entry.
  final TraceLevel level;

  /// Human-readable log message.
  final String message;

  /// Optional category or logger name.
  final String? tag;

  /// Structured key-value data attached to this entry.
  final Map<String, Object?> context;

  /// Optional error object associated with this entry.
  final Object? error;

  /// Optional stack trace (exception stack, not caller stack).
  final StackTrace? stackTrace;

  /// Where the log call originated in source code.
  final CallerInfo? caller;

  /// UTC timestamp when the record was created.
  final DateTime timestamp;

  /// Name of the current isolate, when available.
  final String? isolateName;

  /// OpenTelemetry correlation identifiers, when configured.
  final OtelContext? otel;

  /// Returns a copy with selective field overrides.
  LogRecord copyWith({
    TraceLevel? level,
    String? message,
    String? tag,
    Map<String, Object?>? context,
    Object? error,
    StackTrace? stackTrace,
    CallerInfo? caller,
    DateTime? timestamp,
    String? isolateName,
    OtelContext? otel,
  }) {
    return LogRecord(
      level: level ?? this.level,
      message: message ?? this.message,
      tag: tag ?? this.tag,
      context: context ?? this.context,
      error: error ?? this.error,
      stackTrace: stackTrace ?? this.stackTrace,
      caller: caller ?? this.caller,
      timestamp: timestamp ?? this.timestamp,
      isolateName: isolateName ?? this.isolateName,
      otel: otel ?? this.otel,
    );
  }

  /// Serializes this record to a JSON-compatible map.
  Map<String, Object?> toJson() {
    return {
      'level': level.label,
      'message': message,
      if (tag != null) 'tag': tag,
      if (context.isNotEmpty) 'context': context,
      if (error != null) 'error': error.toString(),
      if (stackTrace != null) 'stackTrace': stackTrace.toString(),
      if (caller != null) 'caller': caller!.toJson(),
      'timestamp': timestamp.toIso8601String(),
      if (isolateName != null) 'isolateName': isolateName,
      if (otel != null) 'otel': otel!.toJson(),
    };
  }
}
