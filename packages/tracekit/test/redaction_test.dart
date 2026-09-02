import 'package:test/test.dart';
import 'package:tracekit/tracekit.dart';

void main() {
  group('Redactor', () {
    late Redactor redactor;

    setUp(() {
      redactor = Redactor(
        const RedactionConfig(
          keys: ['password', 'token'],
          patterns: [r'\b\d{4}-\d{4}-\d{4}-\d{4}\b'],
          replacement: '[REDACTED]',
        ),
      );
    });

    test('redacts sensitive context keys case-insensitively', () {
      final record = LogRecord(
        level: TraceLevel.info,
        message: 'login',
        timestamp: DateTime.utc(2026),
        context: {'Password': 'secret', 'user': 'alice'},
      );
      final result = redactor.redact(record);
      expect(result.context['Password'], '[REDACTED]');
      expect(result.context['user'], 'alice');
    });

    test('redacts nested map values', () {
      final record = LogRecord(
        level: TraceLevel.info,
        message: 'payload',
        timestamp: DateTime.utc(2026),
        context: {
          'user': {'token': 'abc', 'name': 'bob'},
        },
      );
      final result = redactor.redact(record);
      final user = result.context['user'] as Map<String, Object?>;
      expect(user['token'], '[REDACTED]');
      expect(user['name'], 'bob');
    });

    test('redacts regex patterns in message strings', () {
      final record = LogRecord(
        level: TraceLevel.info,
        message: 'card 4111-1111-1111-1111 charged',
        timestamp: DateTime.utc(2026),
      );
      final result = redactor.redact(record);
      expect(result.message, contains('[REDACTED]'));
      expect(result.message, isNot(contains('4111')));
    });

    test('returns original record when config is empty', () {
      final empty = Redactor(const RedactionConfig());
      final record = LogRecord(
        level: TraceLevel.info,
        message: 'plain',
        timestamp: DateTime.utc(2026),
        context: {'password': 'x'},
      );
      expect(empty.redact(record).context['password'], 'x');
    });
  });
}
