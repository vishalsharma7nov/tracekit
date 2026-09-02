import 'package:test/test.dart';
import 'package:tracekit/tracekit.dart';

void main() {
  final record = LogRecord(
    level: TraceLevel.info,
    message: 'test',
    tag: 'Auth',
    timestamp: DateTime.utc(2026),
  );

  group('LevelFilter', () {
    test('passes records at or above min level', () {
      expect(LevelFilter(TraceLevel.info).shouldLog(record), isTrue);
      expect(LevelFilter(TraceLevel.warn).shouldLog(record), isFalse);
    });
  });

  group('TagFilter', () {
    test('passes only allowed tags', () {
      expect(TagFilter({'Auth'}).shouldLog(record), isTrue);
      expect(TagFilter({'Payment'}).shouldLog(record), isFalse);
    });

    test('empty allowed set passes all', () {
      expect(TagFilter({}).shouldLog(record), isTrue);
    });
  });

  group('SampleFilter', () {
    test('rate 0 rejects all', () {
      expect(SampleFilter(0).shouldLog(record), isFalse);
    });

    test('rate 1 accepts all', () {
      expect(SampleFilter(1).shouldLog(record), isTrue);
    });
  });

  group('RateLimitFilter', () {
    test('allows records below min level without limit', () {
      final filter =
          RateLimitFilter(maxPerWindow: 1, minLevel: TraceLevel.error);
      final debugRecord = record.copyWith(level: TraceLevel.debug);
      expect(filter.shouldLog(debugRecord), isTrue);
      expect(filter.shouldLog(debugRecord), isTrue);
    });

    test('rate limits high severity records', () {
      final filter =
          RateLimitFilter(maxPerWindow: 2, minLevel: TraceLevel.warn);
      final warn = record.copyWith(level: TraceLevel.warn);
      expect(filter.shouldLog(warn), isTrue);
      expect(filter.shouldLog(warn), isTrue);
      expect(filter.shouldLog(warn), isFalse);
    });
  });

  group('CallbackFilter', () {
    test('uses custom predicate', () {
      final filter = CallbackFilter((r) => r.message.contains('keep'));
      expect(filter.shouldLog(record.copyWith(message: 'keep me')), isTrue);
      expect(filter.shouldLog(record.copyWith(message: 'drop me')), isFalse);
    });
  });
}
