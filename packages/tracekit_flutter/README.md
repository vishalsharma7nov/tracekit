# tracekit_flutter

Flutter extensions for [tracekit](../tracekit): in-app log viewer, error
handlers, route observer, and debug overlay.

## Quickstart

```dart
import 'package:flutter/material.dart';
import 'package:tracekit/tracekit.dart';
import 'package:tracekit_flutter/tracekit_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TraceKitFlutter.init();
  TraceKitFlutter.runGuarded(() {
    runApp(const MyApp());
  });
}
```

Wrap your app with [TraceLogOverlay] to add a floating log viewer button.

## License

MIT
