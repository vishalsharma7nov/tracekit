import 'package:test/test.dart';
import 'package:tracekit/tracekit.dart';

void main() {
  group('TraceConfig', () {
    test('development preset uses debugOnly caller mode', () {
      final config = TraceConfig.development(isReleaseMode: false);
      expect(config.minLevel, TraceLevel.trace);
      expect(config.callerInfo.mode, CallerInfoMode.debugOnly);
    });

    test('production preset uses errorsOnly caller mode', () {
      final config = TraceConfig.production(isReleaseMode: true);
      expect(config.minLevel, TraceLevel.info);
      expect(config.callerInfo.mode, CallerInfoMode.errorsOnly);
      expect(config.isReleaseMode, isTrue);
    });

    test('fromJson parses minLevel and release flag', () {
      final config = TraceConfig.fromJson({
        'minLevel': 'warn',
        'isReleaseMode': true,
        'captureCallerInfo': false,
      });
      expect(config.minLevel, TraceLevel.warn);
      expect(config.isReleaseMode, isTrue);
      expect(config.captureCallerInfo, isFalse);
    });

    test('copyWith overrides fields', () {
      const original = TraceConfig(minLevel: TraceLevel.info);
      final copy = original.copyWith(minLevel: TraceLevel.error);
      expect(copy.minLevel, TraceLevel.error);
      expect(original.minLevel, TraceLevel.info);
    });
  });

  group('TraceLevel', () {
    test('isAtLeast compares severity', () {
      expect(TraceLevel.error.isAtLeast(TraceLevel.warn), isTrue);
      expect(TraceLevel.debug.isAtLeast(TraceLevel.info), isFalse);
    });
  });

  group('LogRecord', () {
    test('toJson includes core fields', () {
      final record = LogRecord(
        level: TraceLevel.info,
        message: 'hello',
        timestamp: DateTime.utc(2026, 1, 1),
        caller: CallerInfo.manual('main.dart', 1),
        otel: const OtelContext(traceId: 'abc'),
      );
      final json = record.toJson();
      expect(json['level'], 'INFO');
      expect(json['message'], 'hello');
      expect(json['caller'], isA<Map<String, Object?>>());
      expect(json['otel'], isA<Map<String, Object?>>());
    });

    test('copyWith preserves unchanged fields', () {
      final record = LogRecord(
        level: TraceLevel.info,
        message: 'a',
        timestamp: DateTime.utc(2026),
      );
      final copy = record.copyWith(message: 'b');
      expect(copy.level, TraceLevel.info);
      expect(copy.message, 'b');
    });
  });

  group('OtelContextHolder', () {
    test('runWithContext binds trace ids', () {
      const ctx = OtelContext(traceId: 'trace-1', spanId: 'span-1');
      OtelContextHolder.runWithContext(ctx, () {
        expect(OtelContextHolder.current.traceId, 'trace-1');
        expect(OtelContextHolder.current.spanId, 'span-1');
      });
      expect(OtelContextHolder.current.traceId, isNull);
    });
  });
}
