import 'package:dio/dio.dart';
import 'package:tracekit/tracekit.dart';

/// Dio interceptor that logs HTTP requests, responses, and errors via TraceKit.
class TraceKitDioInterceptor extends Interceptor {
  /// Creates [TraceKitDioInterceptor].
  TraceKitDioInterceptor({
    TraceLogger? logger,
    this.logRequestHeaders = true,
    this.logRequestBody = true,
    this.logResponseHeaders = false,
    this.logResponseBody = true,
    this.redactHeaders = const {'authorization', 'cookie', 'set-cookie'},
    this.redactBodyKeys = const {'password', 'token', 'secret'},
  }) : _logger = logger ?? TraceKit.logger;

  final TraceLogger _logger;

  /// Whether to log request headers.
  final bool logRequestHeaders;

  /// Whether to log request bodies.
  final bool logRequestBody;

  /// Whether to log response headers.
  final bool logResponseHeaders;

  /// Whether to log response bodies.
  final bool logResponseBody;

  /// Header names redacted from logs (lowercase).
  final Set<String> redactHeaders;

  /// Body keys redacted from logs (lowercase).
  final Set<String> redactBodyKeys;

  final Map<RequestOptions, DateTime> _startTimes = {};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _startTimes[options] = DateTime.now();
    _logger.info(
      'HTTP ${options.method} ${options.uri}',
      context: {
        if (logRequestHeaders) 'headers': _redactHeaders(options.headers),
        if (logRequestBody && options.data != null)
          'body': _redactBody(options.data),
      },
    );
    handler.next(options);
  }

  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    final started = _startTimes.remove(response.requestOptions);
    final durationMs = started == null
        ? null
        : DateTime.now().difference(started).inMilliseconds;

    _logger.info(
      'HTTP ${response.statusCode} ${response.requestOptions.uri}',
      context: {
        if (durationMs != null) 'durationMs': durationMs,
        if (logResponseHeaders) 'headers': _redactHeaders(response.headers.map),
        if (logResponseBody && response.data != null)
          'body': _redactBody(response.data),
      },
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _startTimes.remove(err.requestOptions);
    _logger.error(
      'HTTP error ${err.requestOptions.method} ${err.requestOptions.uri}',
      error: err,
      stackTrace: err.stackTrace,
      context: {
        'statusCode': err.response?.statusCode,
        'message': err.message,
      },
    );
    handler.next(err);
  }

  Map<String, dynamic> _redactHeaders(Map<String, dynamic> headers) {
    final result = <String, dynamic>{};
    headers.forEach((key, value) {
      if (redactHeaders.contains(key.toLowerCase())) {
        result[key] = '***REDACTED***';
      } else {
        result[key] = value;
      }
    });
    return result;
  }

  Object? _redactBody(Object? data) {
    if (data is Map) {
      final result = <String, dynamic>{};
      data.forEach((key, value) {
        if (key is String && redactBodyKeys.contains(key.toLowerCase())) {
          result[key] = '***REDACTED***';
        } else {
          result[key.toString()] = value;
        }
      });
      return result;
    }
    return data;
  }
}
