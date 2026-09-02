# TraceKit Architecture

## Pipeline

```
Log call → Level check → Context merge → Caller resolve → Redact → Filter → Sink
```

## Core concepts

### TraceLogger

Injectable logger with optional tag and bound context. Use `Trace` for global
access or pass `TraceLogger` via dependency injection.

### Sinks

Destinations for formatted output:

- **ConsoleSink** — stdout/stderr (VM) or browser console (web)
- **MemorySink** — ring buffer for in-app viewer
- **FileSink** — append with rotation
- **RemoteSink** — HTTP batch upload with offline queue
- **CompositeSink** — fan-out to multiple sinks
- **AsyncSink** — buffered async wrapper
- **EncryptedSink** — XOR obfuscation wrapper
- **RoutingSink** — route by tag

### Formatters

Convert `LogRecord` to strings: Pretty, JSON, CompactJson, PlainText.

### Filters

- LevelFilter, TagFilter, SampleFilter, RateLimitFilter, CallbackFilter

### Caller capture

Stack trace parsing via `package:stack_trace`, skipping TraceKit internal
frames. Configurable via `CallerInfoConfig`.

## Extending TraceKit

Implement `TraceSink` and `TraceFormatter` for custom destinations and output
formats.

```dart
class MySink extends TraceSink {
  @override
  TraceLevel get minLevel => TraceLevel.info;

  @override
  TraceFormatter get formatter => const JsonFormatter();

  @override
  void write(LogRecord record) {
    // send to your backend
  }
}
```
