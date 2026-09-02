import 'caller/caller_info.dart';
import 'trace_kit.dart';
import 'trace_logger.dart';

/// Global logging facade. Requires [TraceKit.init] before use.
abstract final class Trace {
  /// Logs at trace level.
  static void trace(
    String message, {
    Map<String, Object?>? context,
    CallerInfo? caller,
  }) =>
      TraceKit.logger.trace(message, context: context, caller: caller);

  /// Logs at debug level.
  static void debug(
    String message, {
    Map<String, Object?>? context,
    CallerInfo? caller,
  }) =>
      TraceKit.logger.debug(message, context: context, caller: caller);

  /// Logs at info level.
  static void info(
    String message, {
    Map<String, Object?>? context,
    CallerInfo? caller,
  }) =>
      TraceKit.logger.info(message, context: context, caller: caller);

  /// Logs at warn level.
  static void warn(
    String message, {
    Map<String, Object?>? context,
    Object? error,
    StackTrace? stackTrace,
    CallerInfo? caller,
  }) =>
      TraceKit.logger.warn(
        message,
        context: context,
        error: error,
        stackTrace: stackTrace,
        caller: caller,
      );

  /// Logs at error level.
  static void error(
    String message, {
    Map<String, Object?>? context,
    Object? error,
    StackTrace? stackTrace,
    CallerInfo? caller,
  }) =>
      TraceKit.logger.error(
        message,
        context: context,
        error: error,
        stackTrace: stackTrace,
        caller: caller,
      );

  /// Logs at fatal level.
  static void fatal(
    String message, {
    Map<String, Object?>? context,
    Object? error,
    StackTrace? stackTrace,
    CallerInfo? caller,
  }) =>
      TraceKit.logger.fatal(
        message,
        context: context,
        error: error,
        stackTrace: stackTrace,
        caller: caller,
      );

  /// Creates a named child logger.
  static TraceLogger child(String tag, {Map<String, Object?>? context}) =>
      TraceKit.child(tag, context: context);
}
