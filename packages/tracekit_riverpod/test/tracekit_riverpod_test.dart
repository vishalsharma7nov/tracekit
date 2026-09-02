import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracekit/tracekit.dart';
import 'package:tracekit_riverpod/tracekit_riverpod.dart';

final counterProvider = StateProvider<int>((ref) => 0);

void main() {
  late MemorySink memory;
  late TraceKitRiverpodObserver observer;

  setUp(() async {
    TraceKit.reset();
    memory = MemorySink();
    await TraceKit.init(
      TraceConfig(sinks: [memory], captureCallerInfo: false),
    );
    observer = TraceKitRiverpodObserver();
  });

  tearDown(() => TraceKit.reset());

  group('TraceKitRiverpodObserver', () {
    test('logs provider add', () {
      final container = ProviderContainer(observers: [observer]);
      addTearDown(container.dispose);

      container.read(counterProvider);
      expect(memory.records.any((r) => r.message == 'Provider added'), isTrue);
    });

    test('logs provider update', () {
      final container = ProviderContainer(observers: [observer]);
      addTearDown(container.dispose);

      container.read(counterProvider.notifier).state = 5;
      expect(
        memory.records.any((r) => r.message == 'Provider updated'),
        isTrue,
      );
    });

    test('logs provider dispose', () {
      final container = ProviderContainer(observers: [observer]);
      container.read(counterProvider);
      container.dispose();
      expect(
        memory.records.any((r) => r.message == 'Provider disposed'),
        isTrue,
      );
    });

    test('logs provider failure', () {
      final container = ProviderContainer(observers: [observer]);
      addTearDown(container.dispose);

      final failing = Provider<int>((ref) => throw StateError('boom'));
      expect(() => container.read(failing), throwsStateError);
      expect(memory.records.last.level, TraceLevel.error);
      expect(memory.records.last.message, 'Provider failed');
    });
  });
}
