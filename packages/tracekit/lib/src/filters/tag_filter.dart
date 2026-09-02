import '../models/log_record.dart';
import 'filter.dart';

/// Filters records by tag/category name.
class TagFilter implements TraceFilter {
  /// Creates a [TagFilter] allowing only [allowedTags].
  const TagFilter(this.allowedTags);

  /// Tags that pass the filter. Empty means allow all.
  final Set<String> allowedTags;

  @override
  bool shouldLog(LogRecord record) {
    if (allowedTags.isEmpty) {
      return true;
    }
    final tag = record.tag;
    return tag != null && allowedTags.contains(tag);
  }
}
