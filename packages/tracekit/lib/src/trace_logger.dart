import 'dart:async';

import 'caller/caller_info.dart';
import 'caller/caller_resolver.dart';
import 'config/trace_config.dart';
import 'context/trace_context.dart';
import 'filters/filter.dart';
import 'filters/level_filter.dart';
import 'models/log_record.dart';
import 'models/trace_level.dart';
import 'otel/otel_context.dart';
import 'redaction/redactor.dart';
import 'sinks/sink.dart';

/// Injectable logger instance with optional tag and bound context.
class TraceLogger {
  /// Creates a [TraceLogger].
  TraceLogger({
    required TraceConfig config,
    this.tag,
    Map<String, Object?>? boundContext,
    TraceLogger? parent,
  })  : _config = config,
        _boundContext = boundContext ?? const {},
        _parent = parent,
        _redactor = Redactor(config.redaction),
        _callerResolver = CallerResolver(
          skipPackagePrefixes: config.callerInfo.skipPackagePrefixes,
        );

  final TraceConfig _config;
  final Map<String, Object?> _boundContext;
  final TraceLogger? _parent;
  final Redactor _redactor;
  final CallerResolver _callerResolver;

  /// Optional category name for this logger.
  final String? tag;

  /// Count of sink failures encountered (for diagnostics).
  static int sinkFailureCount = 0;

  /// Creates a child logger with [tag] and optional extra [context].
  TraceLogger child(String childTag, {Map<String, Object?>? context}) {
    return TraceLogger(
      config: _config,
      tag: childTag,
      boundContext: {..._boundContext, ...?context},
      parent: this,
    );
  }

  /// Logs at [TraceLevel.trace].
  void trace(
    String message, {
    Map<String, Object?>? context,
    CallerInfo? caller,
  }) =>
      _log(TraceLevel.trace, message, context: context, caller: caller);

  /// Logs at [TraceLevel.debug].
  void debug(
    String message, {
    Map<String, Object?>? context,
    CallerInfo? caller,
  }) =>
      _log(TraceLevel.debug, message, context: context, caller: caller);

  /// Logs at [TraceLevel.info].
  void info(
    String message, {
    Map<String, Object?>? context,
    CallerInfo? caller,
  }) =>
      _log(TraceLevel.info, message, context: context, caller: caller);

  /// Logs at [TraceLevel.warn].
  void warn(
    String message, {
    Map<String, Object?>? context,
    Object? error,
    StackTrace? stackTrace,
    CallerInfo? caller,
  }) =>
      _log(
        TraceLevel.warn,
        message,
        context: context,
        error: error,
        stackTrace: stackTrace,
        caller: caller,
      );

  /// Logs at [TraceLevel.error].
  void error(
    String message, {
    Map<String, Object?>? context,
    Object? error,
    StackTrace? stackTrace,
    CallerInfo? caller,
  }) =>
      _log(
        TraceLevel.error,
        message,
        context: context,
        error: error,
        stackTrace: stackTrace,
        caller: caller,
      );

  /// Logs at [TraceLevel.fatal].
  void fatal(
    String message, {
    Map<String, Object?>? context,
    Object? error,
    StackTrace? stackTrace,
    CallerInfo? caller,
  }) =>
      _log(
        TraceLevel.fatal,
        message,
        context: context,
        error: error,
        stackTrace: stackTrace,
        caller: caller,
      );

  void _log(
    TraceLevel level,
    String message, {
    Map<String, Object?>? context,
    Object? error,
    StackTrace? stackTrace,
    CallerInfo? caller,
  }) {
    if (!level.isAtLeast(_config.minLevel)) {
      return;
    }

    final mergedContext = {
      ...?(_parent?._boundContext),
      ..._boundContext,
      ...TraceContext.current,
      ...?context,
    };

    CallerInfo? resolvedCaller = caller;
    if (resolvedCaller == null &&
        _config.captureCallerInfo &&
        _config.callerInfo.shouldCaptureForLevel(
          level,
          isReleaseMode: _config.isReleaseMode,
        )) {
      resolvedCaller = _callerResolver.resolve(StackTrace.current);
    }

    var record = LogRecord(
      level: level,
      message: message,
      tag: tag,
      context: mergedContext,
      error: error,
      stackTrace: stackTrace,
      caller: resolvedCaller,
      timestamp: DateTime.now().toUtc(),
      otel: OtelContextHolder.current,
    );

    record = _redactor.redact(record);

    if (!_passesFilters(record)) {
      return;
    }

    for (final sink in _config.sinks) {
      if (!record.level.isAtLeast(sink.minLevel)) {
        continue;
      }
      try {
        sink.write(record);
      } on Object {
        sinkFailureCount++;
      }
    }
  }

  bool _passesFilters(LogRecord record) {
    final filters = _config.filters;
    if (filters.isEmpty) {
      return true;
    }
    return filters.every((TraceFilter f) => f.shouldLog(record));
  }
}
