import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/log_record.dart';
import '../models/trace_level.dart';
import '../formatters/formatter.dart';
import '../formatters/json_formatter.dart';
import 'sink.dart';

/// Batches log records and ships them to a remote HTTP endpoint.
class RemoteSink extends TraceSink {
  /// Creates a [RemoteSink].
  RemoteSink({
    required this.endpoint,
    this.minLevel = TraceLevel.info,
    TraceFormatter? formatter,
    this.batchSize = 20,
    this.flushInterval = const Duration(seconds: 5),
    HttpClient? httpClient,
  })  : formatter = formatter ?? const JsonFormatter(),
        _client = httpClient ?? HttpClient();

  /// Remote ingestion URL.
  final Uri endpoint;

  @override
  final TraceLevel minLevel;

  @override
  final TraceFormatter formatter;

  /// Records per HTTP request.
  final int batchSize;

  /// Max time before flushing the offline queue.
  final Duration flushInterval;

  final HttpClient _client;
  final List<String> _queue = [];
  Timer? _timer;
  bool _disposed = false;

  /// Starts periodic flush timer.
  void start() {
    _timer ??= Timer.periodic(flushInterval, (_) => flush());
  }

  @override
  void write(LogRecord record) {
    _queue.add(formatter.format(record));
    if (_queue.length >= batchSize) {
      unawaited(flush());
    }
  }

  @override
  Future<void> flush() async {
    if (_queue.isEmpty || _disposed) {
      return;
    }
    final batch = List<String>.from(_queue);
    _queue.clear();
    try {
      final request = await _client.postUrl(endpoint);
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode({'logs': batch}));
      await request.close();
    } on Object {
      // Re-queue on failure for offline support.
      _queue.insertAll(0, batch);
    }
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    _timer?.cancel();
    await flush();
    _client.close(force: true);
  }
}
