import 'dart:io';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:tracekit/tracekit.dart';

import 'helpers/capturing_sink.dart';

void main() {
  group('MemorySink', () {
    test('retains records up to maxEntries', () {
      final sink = MemorySink(maxEntries: 2);
      for (var i = 0; i < 5; i++) {
        sink.write(_record('msg$i'));
      }
      expect(sink.records, hasLength(2));
      expect(sink.records.first.message, 'msg3');
      expect(sink.records.last.message, 'msg4');
    });

    test('clear removes all records', () {
      final sink = MemorySink();
      sink.write(_record('a'));
      sink.clear();
      expect(sink.records, isEmpty);
    });
  });

  group('NoOpSink', () {
    test('discards all records without error', () {
      expect(() => NoOpSink.instance.write(_record('ignored')), returnsNormally);
    });
  });

  group('CompositeSink', () {
    test('writes to all child sinks', () {
      final a = CapturingSink();
      final b = CapturingSink();
      final composite = CompositeSink([a, b]);
      composite.write(_record('fan-out'));
      expect(a.records, hasLength(1));
      expect(b.records, hasLength(1));
    });
  });

  group('RoutingSink', () {
    test('routes by tag to configured sink', () {
      final authSink = CapturingSink();
      final defaultSink = CapturingSink();
      final router = RoutingSink(
        defaultSink: defaultSink,
        routes: {'Auth': authSink},
      );

      router.write(_record('auth log', tag: 'Auth'));
      router.write(_record('default log', tag: 'Other'));

      expect(authSink.records, hasLength(1));
      expect(defaultSink.records, hasLength(1));
      expect(authSink.records.first.message, 'auth log');
    });
  });

  group('AsyncSink', () {
    test('flushes buffered records to delegate', () async {
      final delegate = CapturingSink();
      final async = AsyncSink(delegate: delegate, bufferSize: 10);
      async.write(_record('async'));
      await async.flush();
      expect(delegate.records, hasLength(1));
      await async.dispose();
    });
  });

  group('EncryptedSink', () {
    test('wraps output with encrypted flag in context', () {
      final delegate = CapturingSink();
      final encrypted = EncryptedSink(
        delegate: delegate,
        key: Uint8List.fromList([1, 2, 3, 4]),
      );
      encrypted.write(_record('secret'));
      expect(delegate.records.first.context['encrypted'], isTrue);
      expect(delegate.records.first.message, isNot('secret'));
    });
  });

  group('FileSink', () {
    test('appends formatted lines to file', () async {
      final dir = Directory.systemTemp.createTempSync('tracekit_test');
      final file = File('${dir.path}/test.log');
      final sink = FileSink(file: file);
      sink.write(_record('file log'));
      await sink.flush();
      await sink.dispose();
      expect(file.existsSync(), isTrue);
      expect(file.readAsStringSync(), contains('file log'));
      dir.deleteSync(recursive: true);
    });
  });

  group('ConsoleSink', () {
    test('pretty factory creates sink', () {
      final sink = ConsoleSink.pretty();
      expect(sink.formatter, isA<PrettyFormatter>());
    });

    test('json factory creates sink', () {
      final sink = ConsoleSink.json();
      expect(sink.formatter, isA<JsonFormatter>());
    });
  });
}

LogRecord _record(String message, {String? tag}) {
  return LogRecord(
    level: TraceLevel.info,
    message: message,
    tag: tag,
    timestamp: DateTime.utc(2026, 1, 1),
  );
}
