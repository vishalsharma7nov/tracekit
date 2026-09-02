import '../models/log_record.dart';
import 'formatter.dart';

/// Simple plain-text lines without decoration.
class PlainTextFormatter implements TraceFormatter {
  /// Creates a [PlainTextFormatter].
  const PlainTextFormatter();

  @override
  String format(LogRecord record) {
    final caller = record.caller?.locationLabel;
    final callerPart = caller != null ? ' ($caller)' : '';
    return '${record.level.label}: ${record.message}$callerPart';
  }
}
