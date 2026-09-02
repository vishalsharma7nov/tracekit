import 'package:test/test.dart';
import 'package:tracekit/tracekit.dart';

void main() {
  setUp(() => TraceKit.reset());

  group('TraceKit', () {
    test('throws when logging before init', () {
      expect(() => TraceKit.logger, throwsStateError);
    });

    test('isInitialized reflects init state', () async {
      expect(TraceKit.isInitialized, isFalse);
      await TraceKit.init(
        TraceConfig(sinks: [MemorySink()], captureCallerInfo: false),
      );
      expect(TraceKit.isInitialized, isTrue);
      TraceKit.reset();
      expect(TraceKit.isInitialized, isFalse);
    });

    test('init adds default sinks when none provided', () async {
      await TraceKit.init(TraceConfig(captureCallerInfo: false));
      Trace.info('default sinks');
      expect(TraceKit.config!.sinks, isNotEmpty);
    });
  });

  group('TraceLogger levels', () {
    late MemorySink memory;

    setUp(() async {
      memory = MemorySink();
      await TraceKit.init(
        TraceConfig(
          minLevel: TraceLevel.trace,
          sinks: [memory],
          captureCallerInfo: false,
        ),
      );
    });

    test('logs all severity levels', () {
      Trace.trace('t');
      Trace.debug('d');
      Trace.info('i');
      Trace.warn('w');
      Trace.error('e');
      Trace.fatal('f');
      expect(memory.records, hasLength(6));
      expect(memory.records.map((r) => r.level), [
        TraceLevel.trace,
        TraceLevel.debug,
        TraceLevel.info,
        TraceLevel.warn,
        TraceLevel.error,
        TraceLevel.fatal,
      ]);
    });

    test('error logs include error and stackTrace', () {
      Trace.error(
        'boom',
        error: StateError('bad'),
        stackTrace: StackTrace.current,
      );
      final record = memory.records.last;
      expect(record.error, isA<StateError>());
      expect(record.stackTrace, isNotNull);
    });

    test('merges zone context into record', () {
      TraceContext.runWithContext({'requestId': 'req-1'}, () {
        Trace.info('with context', context: {'userId': 'u1'});
      });
      final record = memory.records.last;
      expect(record.context['requestId'], 'req-1');
      expect(record.context['userId'], 'u1');
    });

    test('uses explicit caller override', () {
      Trace.info(
        'manual caller',
        caller: CallerInfo.manual('checkout.dart', 120),
      );
      expect(memory.records.last.caller?.file, 'checkout.dart');
      expect(memory.records.last.caller?.line, 120);
    });

    test('applies TagFilter from config', () async {
      TraceKit.reset();
      await TraceKit.init(
        TraceConfig(
          sinks: [memory],
          filters: [
            TagFilter({'Payment'})
          ],
          captureCallerInfo: false,
        ),
      );
      Trace.info('ignored');
      Trace.child('Payment').info('kept');
      expect(memory.records, hasLength(1));
      expect(memory.records.first.tag, 'Payment');
    });

    test('child logger inherits bound context', () {
      final payment = Trace.child('Payment', context: {'currency': 'USD'});
      payment.info('charged');
      expect(memory.records.last.tag, 'Payment');
      expect(memory.records.last.context['currency'], 'USD');
    });
  });

  group('Trace facade', () {
    test('Trace.child returns TraceLogger', () async {
      await TraceKit.init(
        TraceConfig(sinks: [MemorySink()], captureCallerInfo: false),
      );
      expect(Trace.child('Test'), isA<TraceLogger>());
    });
  });

  group('Sink failure safety', () {
    test('increments sinkFailureCount when sink throws', () async {
      final failing = _FailingSink();
      TraceLogger.sinkFailureCount = 0;
      await TraceKit.init(
        TraceConfig(sinks: [failing], captureCallerInfo: false),
      );
      Trace.info('should not crash');
      expect(TraceLogger.sinkFailureCount, 1);
    });
  });
}

class _FailingSink extends TraceSink {
  @override
  final TraceLevel minLevel = TraceLevel.trace;

  @override
  final TraceFormatter formatter = const PlainTextFormatter();

  @override
  void write(LogRecord record) => throw Exception('sink failure');
}
