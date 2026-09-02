import '../models/log_record.dart';
import 'redaction_config.dart';

/// Redacts sensitive values from [LogRecord] context and messages.
class Redactor {
  /// Creates a [Redactor].
  Redactor(this.config);

  /// Redaction rules.
  final RedactionConfig config;

  late final List<RegExp> _patterns =
      config.patterns.map(RegExp.new).toList(growable: false);

  late final Set<String> _lowerKeys =
      config.keys.map((k) => k.toLowerCase()).toSet();

  /// Returns a copy of [record] with sensitive data redacted.
  LogRecord redact(LogRecord record) {
    if (config.keys.isEmpty && config.patterns.isEmpty) {
      return record;
    }

    final redactedContext = _redactMap(record.context);
    final redactedMessage = _redactString(record.message);

    return record.copyWith(
      message: redactedMessage,
      context: redactedContext,
    );
  }

  Map<String, Object?> _redactMap(Map<String, Object?> input) {
    final result = <String, Object?>{};
    input.forEach((key, value) {
      if (_lowerKeys.contains(key.toLowerCase())) {
        result[key] = config.replacement;
      } else if (value is String) {
        result[key] = _redactString(value);
      } else if (value is Map<String, Object?>) {
        result[key] = _redactMap(value);
      } else {
        result[key] = value;
      }
    });
    return result;
  }

  String _redactString(String value) {
    var result = value;
    for (final pattern in _patterns) {
      result = result.replaceAll(pattern, config.replacement);
    }
    return result;
  }
}
