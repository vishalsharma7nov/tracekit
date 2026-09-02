import 'config/trace_config.dart';
import 'filters/level_filter.dart';
import 'sinks/console_sink.dart';
import 'sinks/memory_sink.dart';
import 'sinks/sink.dart';
import 'trace_logger.dart';

/// Global initialization and configuration for TraceKit.
class TraceKit {
  TraceKit._();

  static TraceConfig? _config;
  static TraceLogger? _rootLogger;

  /// Whether [init] has been called.
  static bool get isInitialized => _rootLogger != null;

  /// Current configuration, or null before [init].
  static TraceConfig? get config => _config;

  /// Root logger instance.
  static TraceLogger get logger {
    if (_rootLogger == null) {
      throw StateError('TraceKit.init() must be called before logging.');
    }
    return _rootLogger!;
  }

  /// Initializes TraceKit with [config].
  ///
  /// When [config.sinks] is empty, defaults to [ConsoleSink.pretty] and
  /// [MemorySink].
  static Future<void> init(TraceConfig config) async {
    final sinks = config.sinks.isEmpty
        ? <TraceSink>[
            ConsoleSink.pretty(),
            MemorySink(maxEntries: 500),
          ]
        : config.sinks;

    final filters = config.filters.isEmpty
        ? [LevelFilter(config.minLevel)]
        : config.filters;

    _config = config.copyWith(sinks: sinks, filters: filters);
    _rootLogger = TraceLogger(config: _config!);
  }

  /// Resets TraceKit (primarily for tests).
  static void reset() {
    _config = null;
    _rootLogger = null;
  }

  /// Creates a named child logger from the root.
  static TraceLogger child(String tag, {Map<String, Object?>? context}) {
    return logger.child(tag, context: context);
  }
}
