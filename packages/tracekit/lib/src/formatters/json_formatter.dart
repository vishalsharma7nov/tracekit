import '../models/log_record.dart';
import 'formatter.dart';

/// One JSON object per line (JSON Lines / ndjson).
class JsonFormatter implements TraceFormatter {
  /// Creates a [JsonFormatter].
  const JsonFormatter();

  @override
  String format(LogRecord record) {
    return _encode(record.toJson());
  }

  String _encode(Map<String, Object?> map) {
    final buffer = StringBuffer('{');
    var first = true;
    map.forEach((key, value) {
      if (value == null) {
        return;
      }
      if (!first) {
        buffer.write(',');
      }
      first = false;
      buffer
        ..write('"')
        ..write(_escape(key))
        ..write('":')
        ..write(_encodeValue(value));
    });
    buffer.write('}');
    return buffer.toString();
  }

  String _encodeValue(Object? value) {
    if (value is String) {
      return '"${_escape(value)}"';
    }
    if (value is num || value is bool) {
      return value.toString();
    }
    if (value is Map) {
      return _encode(Map<String, Object?>.from(value));
    }
    return '"${_escape(value.toString())}"';
  }

  String _escape(String input) =>
      input.replaceAll('\\', r'\\').replaceAll('"', r'\"');
}
