import '../models/trace_level.dart';

/// Controls when call-site information is captured for log records.
enum CallerInfoMode {
  /// Never capture caller file/line (maximum performance).
  off,

  /// Capture only in non-release builds ([TraceConfig.isReleaseMode] false).
  debugOnly,

  /// Capture for warn, error, and fatal levels only.
  errorsOnly,

  /// Capture on every log call.
  always,
}

/// Configuration for automatic call-site resolution.
class CallerInfoConfig {
  /// Creates [CallerInfoConfig].
  const CallerInfoConfig({
    this.mode = CallerInfoMode.debugOnly,
    this.skipPackagePrefixes = defaultSkipPrefixes,
  });

  /// Default package prefixes skipped when resolving caller frames.
  static const defaultSkipPrefixes = <String>[
    'package:tracekit/',
    'dart:',
    'package:stack_trace/',
  ];

  /// When to capture caller information.
  final CallerInfoMode mode;

  /// URI prefixes to skip when walking the stack trace.
  final List<String> skipPackagePrefixes;

  /// Returns true when caller info should be captured for [level].
  bool shouldCaptureForLevel(
    TraceLevel level, {
    required bool isReleaseMode,
  }) {
    switch (mode) {
      case CallerInfoMode.off:
        return false;
      case CallerInfoMode.debugOnly:
        return !isReleaseMode;
      case CallerInfoMode.errorsOnly:
        return level.value >= TraceLevel.warn.value;
      case CallerInfoMode.always:
        return true;
    }
  }
}
