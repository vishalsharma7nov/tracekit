import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tracekit/tracekit.dart';
import 'package:tracekit_bloc/tracekit_bloc.dart';
import 'package:tracekit_dio/tracekit_dio.dart';
import 'package:tracekit_flutter/tracekit_flutter.dart';
import 'package:tracekit_http/tracekit_http.dart';
import 'package:tracekit_riverpod/tracekit_riverpod.dart';

final counterProvider = StateProvider<int>((ref) => 0);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TraceKitFlutter.init();
  Bloc.observer = TraceKitBlocObserver();

  TraceKitFlutter.runGuarded(() {
    runApp(
      ProviderScope(
        observers: [TraceKitRiverpodObserver()],
        child: const TraceKitExampleApp(),
      ),
    );
  });
}

class TraceKitExampleApp extends StatelessWidget {
  const TraceKitExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TraceKit Example',
      navigatorObservers: [TraceRouteObserver()],
      home: TraceLogOverlay(
        memorySink: TraceKitFlutter.memorySink!,
        child: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TraceKit Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Trace.info('Button tapped');
                Trace.debug('Debug details', context: {'screen': 'home'});
              },
              child: const Text('Log info'),
            ),
            ElevatedButton(
              onPressed: () async {
                final dio = Dio()..interceptors.add(TraceKitDioInterceptor());
                try {
                  await dio.get('https://httpbin.org/get');
                } on Object catch (e, st) {
                  Trace.error('Dio failed', error: e, stackTrace: st);
                }
              },
              child: const Text('Test Dio'),
            ),
            ElevatedButton(
              onPressed: () async {
                final client = TraceKitHttpClient();
                try {
                  await client.get(Uri.parse('https://httpbin.org/get'));
                } finally {
                  client.close();
                }
              },
              child: const Text('Test HTTP'),
            ),
            Consumer(
              builder: (context, ref, _) {
                final count = ref.watch(counterProvider);
                return ElevatedButton(
                  onPressed: () => ref.read(counterProvider.notifier).state++,
                  child: Text('Riverpod count: $count'),
                );
              },
            ),
            BlocProvider(
              create: (_) => CounterCubit(),
              child: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () => context.read<CounterCubit>().increment(),
                    child: BlocBuilder<CounterCubit, int>(
                      builder: (context, count) {
                        return Text('BLoC count: $count');
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
}
