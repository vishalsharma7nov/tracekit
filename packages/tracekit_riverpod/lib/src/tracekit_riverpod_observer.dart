import 'package:riverpod/riverpod.dart';
import 'package:tracekit/tracekit.dart';

/// [ProviderObserver] that logs Riverpod lifecycle events via TraceKit.
class TraceKitRiverpodObserver extends ProviderObserver {
  /// Creates [TraceKitRiverpodObserver].
  TraceKitRiverpodObserver({TraceLogger? logger})
    : _logger = logger ?? TraceKit.logger;

  final TraceLogger _logger;

  @override
  void didAddProvider(
    ProviderBase<dynamic> provider,
    Object? value,
    ProviderContainer container,
  ) {
    _logger.debug(
      'Provider added',
      context: {'provider': provider.name ?? provider.runtimeType.toString()},
    );
  }

  @override
  void didUpdateProvider(
    ProviderBase<dynamic> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    _logger.debug(
      'Provider updated',
      context: {
        'provider': provider.name ?? provider.runtimeType.toString(),
        'previous': previousValue.toString(),
        'new': newValue.toString(),
      },
    );
  }

  @override
  void didDisposeProvider(
    ProviderBase<dynamic> provider,
    ProviderContainer container,
  ) {
    _logger.debug(
      'Provider disposed',
      context: {'provider': provider.name ?? provider.runtimeType.toString()},
    );
  }

  @override
  void providerDidFail(
    ProviderBase<dynamic> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    _logger.error(
      'Provider failed',
      error: error,
      stackTrace: stackTrace,
      context: {'provider': provider.name ?? provider.runtimeType.toString()},
    );
  }
}
