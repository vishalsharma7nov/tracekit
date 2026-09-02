import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:tracekit/tracekit.dart';

/// Flutter-specific initialization wrapping [TraceKit].
class TraceKitFlutter {
  TraceKitFlutter._();

  static MemorySink? _memorySink;
  static FlutterExceptionHandler? _previousFlutterErrorHandler;
  static bool Function(Object, StackTrace)? _previousPlatformErrorHandler;

  /// Memory sink used by the in-app viewer, when configured.
  static MemorySink? get memorySink => _memorySink;

  /// Initializes TraceKit for Flutter with optional error capture.
  static Future<void> init({
    TraceConfig? config,
    bool captureFlutterErrors = true,
    bool capturePlatformErrors = true,
    MemorySink? memorySink,
  }) async {
    final isRelease = kReleaseMode;
    _memorySink = memorySink ?? MemorySink(maxEntries: 1000);

    final baseConfig =
        config ?? TraceConfig.development(isReleaseMode: isRelease);
    final sinks = baseConfig.sinks.isEmpty
        ? <TraceSink>[ConsoleSink.pretty(), _memorySink!]
        : baseConfig.sinks;

    await TraceKit.init(
      baseConfig.copyWith(
        isReleaseMode: isRelease,
        sinks: sinks,
      ),
    );

    if (captureFlutterErrors) {
      _previousFlutterErrorHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        Trace.error(
          details.exceptionAsString(),
          error: details.exception,
          stackTrace: details.stack,
          context: {
            'library': details.library ?? '',
            'context': details.context?.toString() ?? '',
          },
        );
        _previousFlutterErrorHandler?.call(details);
      };
    }

    if (capturePlatformErrors) {
      _previousPlatformErrorHandler = PlatformDispatcher.instance.onError;
      PlatformDispatcher.instance.onError = (error, stack) {
        Trace.fatal(
          'Uncaught platform error',
          error: error,
          stackTrace: stack,
        );
        return _previousPlatformErrorHandler?.call(error, stack) ?? false;
      };
    }
  }

  /// Runs [body] inside a guarded zone that logs uncaught async errors.
  static void runGuarded(VoidCallback body) {
    runZonedGuarded(
      body,
      (error, stack) {
        Trace.fatal(
          'Uncaught zone error',
          error: error,
          stackTrace: stack,
        );
      },
    );
  }
}
