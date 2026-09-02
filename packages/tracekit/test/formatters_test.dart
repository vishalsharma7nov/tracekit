import 'package:test/test.dart';
import 'package:tracekit/tracekit.dart';

void main() {
  final record = LogRecord(
    level: TraceLevel.warn,
    message: 'payment failed',
    tag: 'Payment',
    timestamp: DateTime.utc(2026, 3, 15, 10, 30),
    caller: CallerInfo.manual('pay.dart', 99, member: 'charge'),
    context: {'orderId': '123'},
  );

  group('PrettyFormatter', () {
    test('includes level, message, tag, and caller', () {
      const formatter = PrettyFormatter();
      final output = formatter.format(record);
      expect(output, contains('[WARN]'));
      expect(output, contains('payment failed'));
      expect(output, contains('Payment'));
      expect(output, contains('pay.dart:99'));
    });
  });

  group('JsonFormatter', () {
    test('outputs valid JSON line', () {
      const formatter = JsonFormatter();
      final output = formatter.format(record);
      expect(output, contains('"level":"WARN"'));
      expect(output, contains('"message":"payment failed"'));
      expect(output, contains('"tag":"Payment"'));
    });
  });

  group('PlainTextFormatter', () {
    test('includes level and caller location', () {
      const formatter = PlainTextFormatter();
      final output = formatter.format(record);
      expect(output, contains('WARN: payment failed'));
      expect(output, contains('pay.dart:99'));
    });
  });

  group('CompactJsonFormatter', () {
    test('outputs compact key-value pairs', () {
      const formatter = CompactJsonFormatter();
      final output = formatter.format(record);
      expect(output, contains('"level":"WARN"'));
      expect(output, contains('"message":"payment failed"'));
    });
  });
}
