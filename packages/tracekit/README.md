# tracekit

Structured logging for Dart and Flutter. Replaces `print()`, `log()`, and
`debugPrint()` with levels, sinks, call-site capture, and PII redaction.

## Features

- Log levels: trace, debug, info, warn, error, fatal
- Sink pipeline: console, memory, file, remote, composite
- Automatic caller file:line capture via stack trace parsing
- PII redaction for context maps and regex patterns
- Zone-based MDC context propagation
- Pure Dart core — no Flutter dependency

## Quickstart

```dart
import 'package:tracekit/tracekit.dart';

Future<void> main() async {
  await TraceKit.init(TraceConfig(
    minLevel: TraceLevel.debug,
    sinks: [ConsoleSink.pretty(), MemorySink(maxEntries: 500)],
    redaction: RedactionConfig(keys: ['password', 'token']),
  ));

  Trace.info('User signed in', context: {'userId': '42'});
  Trace.error('Payment failed', error: Exception('timeout'));
}
```

## Platform support

| Platform | Supported |
| -------- | --------- |
| Android  | Yes       |
| iOS      | Yes       |
| Web      | Yes       |
| macOS    | Yes       |
| Windows  | Yes       |
| Linux    | Yes       |

## Benchmark

With caller info disabled (production mode):

```
TraceKit: 10000 logs in ~23ms (~2.4 µs/log, ~430K logs/sec)
```

Run: `dart run benchmark/benchmark.dart`

## License

MIT — see [LICENSE](../../LICENSE).
