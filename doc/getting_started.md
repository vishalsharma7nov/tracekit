# Getting Started with TraceKit

## Installation

```yaml
dependencies:
  tracekit: ^0.1.0
  tracekit_flutter: ^0.2.0
```

## Initialize

```dart
await TraceKitFlutter.init(
  config: TraceConfig(
    minLevel: TraceLevel.debug,
    redaction: RedactionConfig(keys: ['password', 'token']),
    callerInfo: CallerInfoConfig(mode: CallerInfoMode.debugOnly),
  ),
);
```

## Log messages

```dart
Trace.info('User signed in', context: {'userId': id});
Trace.error('Failed', error: e, stackTrace: st);

final auth = Trace.child('Auth');
auth.debug('Token refreshed');
```

## In-app viewer

```dart
TraceLogOverlay(
  memorySink: TraceKitFlutter.memorySink!,
  child: MyApp(),
)
```

Tap the floating button to open the log viewer.

## Production config

```dart
await TraceKitFlutter.init(
  config: TraceConfig.production(
    sinks: [FileSink(file: logFile)],
  ),
);
```

Caller info is automatically disabled in release builds when using
`CallerInfoMode.debugOnly`.
