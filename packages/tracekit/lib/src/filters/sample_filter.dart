import '../models/log_record.dart';
import 'filter.dart';

/// Randomly samples a fraction of log records for high-volume scenarios.
class SampleFilter implements TraceFilter {
  /// Creates a [SampleFilter] that passes approximately [rate] records.
  ///
  /// [rate] must be between 0.0 and 1.0 inclusive.
  SampleFilter(this.rate) : assert(rate >= 0 && rate <= 1);

  /// Fraction of records to pass (1.0 = all, 0.1 = ~10%).
  final double rate;

  static int _counter = 0;

  @override
  bool shouldLog(LogRecord record) {
    if (rate >= 1.0) {
      return true;
    }
    if (rate <= 0) {
      return false;
    }
    _counter++;
    return (_counter % (1 / rate).round()) == 0;
  }
}
