/// Configuration for sensitive data redaction before logs are emitted.
class RedactionConfig {
  /// Creates [RedactionConfig].
  const RedactionConfig({
    this.keys = const [],
    this.patterns = const [],
    this.replacement = '***REDACTED***',
  });

  /// Context map keys whose values are redacted (case-insensitive).
  final List<String> keys;

  /// Regex patterns matched against string values.
  final List<String> patterns;

  /// Replacement text for redacted values.
  final String replacement;
}
