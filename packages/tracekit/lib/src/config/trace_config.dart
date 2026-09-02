import '../models/trace_level.dart';
import '../caller/caller_info_config.dart';
import '../redaction/redaction_config.dart';
import '../sinks/sink.dart';
import '../filters/filter.dart';

/// Central configuration for [TraceKit] and [TraceLogger] instances.
class TraceConfig {
  /// Creates [TraceConfig].
  const TraceConfig({
    this.minLevel = TraceLevel.debug,
    this.sinks = const [],
    this.filters = const [],
    this.redaction = const RedactionConfig(),
    this.callerInfo = const CallerInfoConfig(),
    this.isReleaseMode = false,
    this.captureCallerInfo = true,
  });

  /// Development preset with pretty console and memory sinks.
  factory TraceConfig.development({
    List<TraceSink> extraSinks = const [],
    bool isReleaseMode = false,
  }) {
    return TraceConfig(
      minLevel: TraceLevel.trace,
      isReleaseMode: isReleaseMode,
      callerInfo: const CallerInfoConfig(mode: CallerInfoMode.debugOnly),
    );
  }

  /// Production preset: info level, no caller info in release.
  factory TraceConfig.production({
    List<TraceSink> sinks = const [],
    bool isReleaseMode = true,
  }) {
    return TraceConfig(
      minLevel: TraceLevel.info,
      sinks: sinks,
      isReleaseMode: isReleaseMode,
      callerInfo: const CallerInfoConfig(mode: CallerInfoMode.errorsOnly),
    );
  }

  /// Staging preset between dev and prod.
  factory TraceConfig.staging({bool isReleaseMode = false}) {
    return TraceConfig(
      minLevel: TraceLevel.debug,
      isReleaseMode: isReleaseMode,
      callerInfo: const CallerInfoConfig(mode: CallerInfoMode.errorsOnly),
    );
  }

  /// Creates config from a JSON map.
  factory TraceConfig.fromJson(Map<String, Object?> json) {
    final levelName = json['minLevel'] as String? ?? 'debug';
    return TraceConfig(
      minLevel: TraceLevel.values.firstWhere(
        (l) => l.label == levelName.toUpperCase(),
        orElse: () => TraceLevel.debug,
      ),
      isReleaseMode: json['isReleaseMode'] as bool? ?? false,
      captureCallerInfo: json['captureCallerInfo'] as bool? ?? true,
    );
  }

  /// Minimum level emitted by the root logger.
  final TraceLevel minLevel;

  /// Sinks that receive formatted log output.
  final List<TraceSink> sinks;

  /// Filters applied before records reach sinks.
  final List<TraceFilter> filters;

  /// PII and sensitive value redaction rules.
  final RedactionConfig redaction;

  /// Call-site capture settings.
  final CallerInfoConfig callerInfo;

  /// When true, [CallerInfoMode.debugOnly] skips capture.
  final bool isReleaseMode;

  /// Master switch for caller resolution (lazy optimization).
  final bool captureCallerInfo;

  /// Returns a copy with selective overrides.
  TraceConfig copyWith({
    TraceLevel? minLevel,
    List<TraceSink>? sinks,
    List<TraceFilter>? filters,
    RedactionConfig? redaction,
    CallerInfoConfig? callerInfo,
    bool? isReleaseMode,
    bool? captureCallerInfo,
  }) {
    return TraceConfig(
      minLevel: minLevel ?? this.minLevel,
      sinks: sinks ?? this.sinks,
      filters: filters ?? this.filters,
      redaction: redaction ?? this.redaction,
      callerInfo: callerInfo ?? this.callerInfo,
      isReleaseMode: isReleaseMode ?? this.isReleaseMode,
      captureCallerInfo: captureCallerInfo ?? this.captureCallerInfo,
    );
  }
}
