import 'package:flutter_test/flutter_test.dart';
import 'package:tracekit/tracekit.dart';
import 'package:tracekit_flutter/tracekit_flutter.dart';

void main() {
  setUp(() => TraceKit.reset());

  group('TraceKitFlutter', () {
    test('init configures memory sink', () async {
      final memory = MemorySink(maxEntries: 5);
      await TraceKitFlutter.init(
        config: TraceConfig(sinks: [memory], captureCallerInfo: false),
        memorySink: memory,
        captureFlutterErrors: false,
        capturePlatformErrors: false,
      );
      Trace.info('flutter test');
      expect(memory.records, isNotEmpty);
    });

    test('memorySink is accessible after init', () async {
      await TraceKitFlutter.init(
        captureFlutterErrors: false,
        capturePlatformErrors: false,
      );
      expect(TraceKitFlutter.memorySink, isNotNull);
    });
  });

  group('LogExporter', () {
    test('exportAsJson returns JSON array', () {
      final memory = MemorySink();
      memory.write(
        LogRecord(
          level: TraceLevel.info,
          message: 'export me',
          timestamp: DateTime.utc(2026),
        ),
      );
      final json = LogExporter(memory).exportAsJson();
      expect(json, contains('export me'));
      expect(json, contains('INFO'));
    });

    test('exportAsText returns formatted lines', () {
      final memory = MemorySink();
      memory.write(
        LogRecord(
          level: TraceLevel.warn,
          message: 'warn line',
          timestamp: DateTime.utc(2026, 1, 1),
        ),
      );
      final text = LogExporter(memory).exportAsText();
      expect(text, contains('[WARN]'));
      expect(text, contains('warn line'));
    });
  });

  group('TraceRouteObserver', () {
    test('can be constructed', () async {
      await TraceKitFlutter.init(
        captureFlutterErrors: false,
        capturePlatformErrors: false,
      );
      expect(TraceRouteObserver(), isNotNull);
    });
  });
}
