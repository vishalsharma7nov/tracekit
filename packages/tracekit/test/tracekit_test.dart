import 'package:test/test.dart';
import 'package:tracekit/tracekit.dart';

void main() {
  setUp(() {
    TraceKit.reset();
  });

  group('TraceLogger', () {
    test('writes to memory sink', () async {
      final memory = MemorySink(maxEntries: 10);
      await TraceKit.init(
        TraceConfig(
          minLevel: TraceLevel.debug,
          sinks: [memory],
          captureCallerInfo: false,
        ),
      );

      Trace.info('hello', context: {'userId': 1});
      expect(memory.records, hasLength(1));
      expect(memory.records.first.message, 'hello');
      expect(memory.records.first.level, TraceLevel.info);
    });

    test('respects min level', () async {
      final memory = MemorySink();
      await TraceKit.init(
        TraceConfig(
          minLevel: TraceLevel.warn,
          sinks: [memory],
          captureCallerInfo: false,
        ),
      );

      Trace.debug('hidden');
      Trace.warn('visible');
      expect(memory.records, hasLength(1));
      expect(memory.records.first.message, 'visible');
    });

    test('child logger uses tag', () async {
      final memory = MemorySink();
      await TraceKit.init(
        TraceConfig(
          sinks: [memory],
          captureCallerInfo: false,
        ),
      );

      Trace.child('Auth').info('signed in');
      expect(memory.records.first.tag, 'Auth');
    });
  });

  group('Redactor', () {
    test('redacts sensitive keys', () {
      final redactor = Redactor(
        const RedactionConfig(keys: ['password', 'token']),
      );
      final record = LogRecord(
        level: TraceLevel.info,
        message: 'login',
        timestamp: DateTime.utc(2026),
        context: {'password': 'secret', 'user': 'alice'},
      );
      final redacted = redactor.redact(record);
      expect(redacted.context['password'], '***REDACTED***');
      expect(redacted.context['user'], 'alice');
    });
  });

  group('CallerInfo', () {
    test('manual caller info', () {
      final caller = CallerInfo.manual('auth.dart', 42, member: 'signIn');
      expect(caller.locationLabel, 'auth.dart:42');
      expect(caller.member, 'signIn');
    });
  });

  group('TraceContext', () {
    test('propagates zone context', () {
      TraceContext.runWithContext({'requestId': 'abc'}, () {
        expect(TraceContext.current['requestId'], 'abc');
      });
    });
  });

  group('Filters', () {
    test('SampleFilter passes fraction of records', () {
      final filter = SampleFilter(1.0);
      final record = LogRecord(
        level: TraceLevel.info,
        message: 'x',
        timestamp: DateTime.utc(2026),
      );
      expect(filter.shouldLog(record), isTrue);
    });
  });

  group('Formatters', () {
    test('PrettyFormatter includes level and message', () {
      const formatter = PrettyFormatter(includeCaller: false);
      final output = formatter.format(
        LogRecord(
          level: TraceLevel.info,
          message: 'test',
          timestamp: DateTime.utc(2026, 1, 1),
        ),
      );
      expect(output, contains('[INFO]'));
      expect(output, contains('test'));
    });
  });
}
