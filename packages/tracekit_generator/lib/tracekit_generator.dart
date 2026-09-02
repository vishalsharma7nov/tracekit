/// Compile-time caller injection helpers for TraceKit.
///
/// Full code generation via build_runner can be added in future releases.
/// For now, use [CallerInfo.here()] at call sites or stack-based capture.
library tracekit_generator;

export 'package:tracekit/tracekit.dart' show CallerInfo;

/// Marker annotation for future codegen of call-site metadata.
class TraceLog {
  /// Creates a [TraceLog] annotation.
  const TraceLog();
}
