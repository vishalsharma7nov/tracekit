import 'package:tracekit/tracekit.dart';

/// Throughput benchmark for TraceKit logging (caller info disabled).
void main() async {
  final memory = MemorySink(maxEntries: 100000);
  await TraceKit.init(
    TraceConfig(
      sinks: [memory],
      captureCallerInfo: false,
      isReleaseMode: true,
    ),
  );

  const iterations = 10000;
  final stopwatch = Stopwatch()..start();
  for (var i = 0; i < iterations; i++) {
    Trace.info('benchmark message', context: {'i': i});
  }
  stopwatch.stop();

  final perLogUs = stopwatch.elapsedMicroseconds / iterations;
  // Benchmark output uses stdout directly (not TraceKit API).
  // ignore: avoid_print
  print(
    'TraceKit: $iterations logs in ${stopwatch.elapsedMilliseconds}ms '
    '(${perLogUs.toStringAsFixed(2)} µs/log)',
  );
}
