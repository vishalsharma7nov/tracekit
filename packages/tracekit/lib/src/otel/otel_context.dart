/// OpenTelemetry-style correlation identifiers for distributed tracing.
class OtelContext {
  /// Creates [OtelContext].
  const OtelContext({
    this.traceId,
    this.spanId,
    this.traceFlags,
  });

  /// 128-bit trace identifier (hex string).
  final String? traceId;

  /// 64-bit span identifier (hex string).
  final String? spanId;

  /// W3C trace flags, when available.
  final String? traceFlags;

  /// Serializes to JSON.
  Map<String, Object?> toJson() => {
        if (traceId != null) 'traceId': traceId,
        if (spanId != null) 'spanId': spanId,
        if (traceFlags != null) 'traceFlags': traceFlags,
      };

  /// Empty context with no identifiers.
  static const empty = OtelContext();
}

/// Holds optional OpenTelemetry context for the current zone or logger.
class OtelContextHolder {
  OtelContextHolder._();

  static OtelContext _current = OtelContext.empty;

  /// Current OTel context.
  static OtelContext get current => _current;

  /// Runs [action] with [context] bound as the current OTel context.
  static T runWithContext<T>(OtelContext context, T Function() action) {
    final previous = _current;
    _current = context;
    try {
      return action();
    } finally {
      _current = previous;
    }
  }
}
