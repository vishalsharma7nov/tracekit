import '../models/log_record.dart';
import '../models/trace_level.dart';
import '../formatters/formatter.dart';
import 'sink.dart';

/// Buffers log writes and flushes them asynchronously to a delegate sink.
class AsyncSink extends TraceSink {
  /// Creates an [AsyncSink] wrapping [delegate].
  AsyncSink({
    required this.delegate,
    this.bufferSize = 100,
    this.flushInterval = const Duration(milliseconds: 500),
  }) {
    _startTimer();
  }

  /// Underlying sink receiving batched records.
  final TraceSink delegate;

  /// Max records before an immediate flush.
  final int bufferSize;

  /// Periodic flush interval.
  final Duration flushInterval;

  @override
  TraceLevel get minLevel => delegate.minLevel;

  @override
  TraceFormatter get formatter => delegate.formatter;

  final List<LogRecord> _buffer = [];
  bool _disposed = false;

  void _startTimer() {
    Future<void>.delayed(flushInterval, () async {
      if (_disposed) {
        return;
      }
      await flush();
      _startTimer();
    });
  }

  @override
  void write(LogRecord record) {
    _buffer.add(record);
    if (_buffer.length >= bufferSize) {
      flush();
    }
  }

  @override
  Future<void> flush() async {
    if (_buffer.isEmpty) {
      return;
    }
    final batch = List<LogRecord>.from(_buffer);
    _buffer.clear();
    for (final record in batch) {
      delegate.write(record);
    }
    await delegate.flush();
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    await flush();
    await delegate.dispose();
  }
}
