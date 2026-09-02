import 'package:bloc/bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tracekit/tracekit.dart';
import 'package:tracekit_bloc/tracekit_bloc.dart';

void main() {
  late MemorySink memory;
  late TraceKitBlocObserver observer;

  setUp(() async {
    TraceKit.reset();
    memory = MemorySink();
    await TraceKit.init(
      TraceConfig(sinks: [memory], captureCallerInfo: false),
    );
    observer = TraceKitBlocObserver();
  });

  tearDown(() => TraceKit.reset());

  group('TraceKitBlocObserver', () {
    test('logs bloc creation', () {
      final bloc = _TestBloc();
      observer.onCreate(bloc);
      expect(memory.records.last.message, 'BLoC created');
      expect(memory.records.last.context['bloc'], contains('_TestBloc'));
      bloc.close();
    });

    test('logs bloc events and transitions', () {
      final bloc = _TestBloc();
      observer.onCreate(bloc);
      const event = _IncrementEvent();
      observer.onEvent(bloc, event);
      observer.onTransition(
        bloc,
        const Transition(
          currentState: 0,
          event: event,
          nextState: 1,
        ),
      );
      expect(memory.records.any((r) => r.message == 'BLoC event'), isTrue);
      expect(
        memory.records.any((r) => r.message == 'BLoC transition'),
        isTrue,
      );
      bloc.close();
    });

    test('logs bloc errors', () {
      final bloc = _TestBloc();
      observer.onError(bloc, StateError('fail'), StackTrace.current);
      expect(memory.records.last.level, TraceLevel.error);
      expect(memory.records.last.message, 'BLoC error');
      bloc.close();
    });

    test('logs bloc close', () {
      final bloc = _TestBloc();
      observer.onClose(bloc);
      expect(memory.records.last.message, 'BLoC closed');
    });

    test('logs cubit lifecycle via BlocBase hooks', () {
      final cubit = _TestCubit();
      observer.onCreate(cubit);
      observer.onClose(cubit);
      expect(memory.records.first.message, 'BLoC created');
      expect(memory.records.last.message, 'BLoC closed');
    });
  });
}

class _TestBloc extends Bloc<_IncrementEvent, int> {
  _TestBloc() : super(0) {
    on<_IncrementEvent>((event, emit) => emit(state + 1));
  }
}

class _TestCubit extends Cubit<int> {
  _TestCubit() : super(0);
}

class _IncrementEvent {
  const _IncrementEvent();

  @override
  String toString() => 'Increment';
}
