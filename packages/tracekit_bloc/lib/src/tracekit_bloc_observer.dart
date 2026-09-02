import 'package:bloc/bloc.dart';
import 'package:tracekit/tracekit.dart';

/// [BlocObserver] that logs BLoC lifecycle events via TraceKit.
class TraceKitBlocObserver extends BlocObserver {
  /// Creates [TraceKitBlocObserver].
  TraceKitBlocObserver({TraceLogger? logger})
    : _logger = logger ?? TraceKit.logger;

  final TraceLogger _logger;

  @override
  void onCreate(BlocBase<dynamic> bloc) {
    super.onCreate(bloc);
    _logger.debug(
      'BLoC created',
      context: {'bloc': bloc.runtimeType.toString()},
    );
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    _logger.debug(
      'BLoC event',
      context: {'bloc': bloc.runtimeType.toString(), 'event': event.toString()},
    );
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    _logger.debug(
      'BLoC transition',
      context: {
        'bloc': bloc.runtimeType.toString(),
        'event': transition.event.toString(),
        'currentState': transition.currentState.toString(),
        'nextState': transition.nextState.toString(),
      },
    );
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    _logger.error(
      'BLoC error',
      error: error,
      stackTrace: stackTrace,
      context: {'bloc': bloc.runtimeType.toString()},
    );
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    super.onClose(bloc);
    _logger.debug(
      'BLoC closed',
      context: {'bloc': bloc.runtimeType.toString()},
    );
  }
}
