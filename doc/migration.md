# Migration Guide

## From print / debugPrint

| Before | After |
| ------ | ----- |
| `print('hello')` | `Trace.info('hello')` |
| `debugPrint('debug')` | `Trace.debug('debug')` |
| `log('msg')` | `Trace.info('msg')` |

Enable `avoid_print` in analysis_options.yaml.

## From package:logger

| logger | TraceKit |
| ------ | -------- |
| `Logger('Auth')` | `Trace.child('Auth')` |
| `logger.info('msg')` | `Trace.info('msg')` |
| `Logger.root.level = Level.INFO` | `TraceConfig(minLevel: TraceLevel.info)` |
| `Logger.root.onRecord.listen` | Custom `TraceSink` |

## From Talker

| Talker | TraceKit |
| ------ | -------- |
| `talker.info('msg')` | `Trace.info('msg')` |
| `TalkerFlutter.init()` | `TraceKitFlutter.init()` |
| Talker screen | `TraceLogViewer` |
| `TalkerDioLogger` | `TraceKitDioInterceptor` |
| `TalkerBlocObserver` | `TraceKitBlocObserver` |

## Caller info

TraceKit captures file:line automatically. No manual `#file`/`#line` required
unless you want zero stack overhead:

```dart
Trace.info('msg', caller: CallerInfo.here());
```
