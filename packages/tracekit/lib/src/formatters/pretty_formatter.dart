import '../models/log_record.dart';
import 'formatter.dart';

/// Human-readable colored-style output for development consoles.
class PrettyFormatter implements TraceFormatter {
  /// Creates a [PrettyFormatter].
  const PrettyFormatter({
    this.includeTimestamp = true,
    this.includeCaller = true,
    this.includeTag = true,
  });

  /// Whether to prefix lines with ISO timestamps.
  final bool includeTimestamp;

  /// Whether to include caller file:line.
  final bool includeCaller;

  /// Whether to include the logger tag.
  final bool includeTag;

  @override
  String format(LogRecord record) {
    final parts = <String>['[${record.level.label}]'];

    if (includeTimestamp) {
      parts.add(record.timestamp.toIso8601String());
    }
    if (includeTag && record.tag != null) {
      parts.add(record.tag!);
    }
    if (includeCaller && record.caller != null) {
      parts.add(record.caller!.toString());
    }

    final prefix = parts.join(' ');
    final contextStr = record.context.isEmpty ? '' : ' ${record.context}';
    final errorStr = record.error != null ? ' | ${record.error}' : '';
    return '$prefix · ${record.message}$contextStr$errorStr';
  }
}
