# TraceKit

Structured logging ecosystem for Dart and Flutter. Replaces `print()`, `log()`,
and `debugPrint()` with levels, sinks, call-site capture, redaction, and
optional Flutter UI.

## Packages

| Package | Description |
| ------- | ----------- |
| [tracekit](packages/tracekit) | Pure Dart core logger |
| [tracekit_flutter](packages/tracekit_flutter) | Flutter UI, error handlers, route observer |
| [tracekit_dio](packages/tracekit_dio) | Dio HTTP interceptor |
| [tracekit_http](packages/tracekit_http) | `package:http` client wrapper |
| [tracekit_bloc](packages/tracekit_bloc) | BLoC observer |
| [tracekit_riverpod](packages/tracekit_riverpod) | Riverpod observer |
| [tracekit_lints](packages/tracekit_lints) | Recommended lint rules |
| [tracekit_generator](packages/tracekit_generator) | Compile-time caller helpers |

## Quickstart

```dart
import 'package:tracekit/tracekit.dart';
import 'package:tracekit_flutter/tracekit_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TraceKitFlutter.init();
  Trace.info('App started');
}
```

## Features

- Log levels: trace, debug, info, warn, error, fatal
- Sinks: console, memory, file, remote, composite, encrypted
- Automatic caller file:line via stack trace parsing
- PII redaction, zone-based MDC context
- In-app log viewer with search, filter, export
- HTTP interceptors for Dio and http
- BLoC and Riverpod observers

## Platform support

| Platform | Supported |
| -------- | --------- |
| Android  | Yes |
| iOS      | Yes |
| Web      | Yes |
| macOS    | Yes |
| Windows  | Yes |
| Linux    | Yes |

## Development

```bash
dart pub global activate melos
melos bootstrap
melos run analyze
melos run test
```

## Publishing

```bash
cd packages/tracekit && dart pub publish --dry-run
```

Publish order: `tracekit` → `tracekit_flutter` → plugins.

## Documentation

- [Getting started](doc/getting_started.md)
- [Architecture](doc/architecture.md)
- [Migration guide](doc/migration.md)

## License

MIT — see [LICENSE](LICENSE).
