import '../models/log_record.dart';
import '../models/trace_level.dart';
import 'filter.dart';

/// Limits log throughput per level within a time window.
class RateLimitFilter implements TraceFilter {
  /// Creates a [RateLimitFilter].
  RateLimitFilter({
    this.maxPerWindow = 100,
    this.window = const Duration(seconds: 1),
    this.minLevel = TraceLevel.warn,
  });

  /// Maximum records per [window].
  final int maxPerWindow;

  /// Rolling time window.
  final Duration window;

  /// Only rate-limit levels at or above [minLevel].
  final TraceLevel minLevel;

  final Map<TraceLevel, _WindowCounter> _counters = {};

  @override
  bool shouldLog(LogRecord record) {
    if (!record.level.isAtLeast(minLevel)) {
      return true;
    }
    final counter = _counters.putIfAbsent(
      record.level,
      () => _WindowCounter(window),
    );
    return counter.tryAcquire(maxPerWindow);
  }
}

class _WindowCounter {
  _WindowCounter(this.window);

  final Duration window;
  int _count = 0;
  DateTime _windowStart = DateTime.now();

  bool tryAcquire(int max) {
    final now = DateTime.now();
    if (now.difference(_windowStart) > window) {
      _windowStart = now;
      _count = 0;
    }
    if (_count >= max) {
      return false;
    }
    _count++;
    return true;
  }
}
