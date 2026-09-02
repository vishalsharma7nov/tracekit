import 'package:http/http.dart' as http;
import 'package:tracekit/tracekit.dart';

/// [BaseClient] wrapper that logs HTTP traffic via TraceKit.
class TraceKitHttpClient extends http.BaseClient {
  /// Creates [TraceKitHttpClient] wrapping [inner].
  TraceKitHttpClient({
    http.Client? inner,
    TraceLogger? logger,
    this.redactHeaders = const {'authorization', 'cookie'},
  })  : _inner = inner ?? http.Client(),
        _logger = logger ?? TraceKit.logger;

  final http.Client _inner;
  final TraceLogger _logger;

  /// Header names redacted from logs (lowercase).
  final Set<String> redactHeaders;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final started = DateTime.now();
    _logger.info(
      'HTTP ${request.method} ${request.url}',
      context: {
        'headers': _redact(request.headers),
      },
    );

    try {
      final response = await _inner.send(request);
      final durationMs = DateTime.now().difference(started).inMilliseconds;
      _logger.info(
        'HTTP ${response.statusCode} ${request.url}',
        context: {'durationMs': durationMs},
      );
      return response;
    } catch (error, stackTrace) {
      _logger.error(
        'HTTP error ${request.method} ${request.url}',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Map<String, String> _redact(Map<String, String> headers) {
    return {
      for (final entry in headers.entries)
        entry.key: redactHeaders.contains(entry.key.toLowerCase())
            ? '***REDACTED***'
            : entry.value,
    };
  }

  @override
  void close() {
    _inner.close();
  }
}
