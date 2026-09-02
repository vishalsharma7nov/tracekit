# tracekit_http

`package:http` client wrapper for TraceKit logging.

```dart
final client = TraceKitHttpClient();
final response = await client.get(Uri.parse('https://example.com'));
```
