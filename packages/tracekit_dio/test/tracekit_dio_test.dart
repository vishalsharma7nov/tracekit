import 'package:dio/dio.dart';
import 'package:test/test.dart';
import 'package:tracekit/tracekit.dart';
import 'package:tracekit_dio/tracekit_dio.dart';

void main() {
  late MemorySink memory;
  late TraceKitDioInterceptor interceptor;

  setUp(() async {
    TraceKit.reset();
    memory = MemorySink();
    await TraceKit.init(
      TraceConfig(sinks: [memory], captureCallerInfo: false),
    );
    interceptor = TraceKitDioInterceptor();
  });

  tearDown(() => TraceKit.reset());

  group('TraceKitDioInterceptor', () {
    test('logs request on onRequest', () {
      final options = RequestOptions(path: 'https://api.test/users');
      final handler = _FakeRequestHandler();

      interceptor.onRequest(options, handler);

      expect(handler.called, isTrue);
      expect(memory.records, hasLength(1));
      expect(memory.records.first.message, contains('GET'));
      expect(memory.records.first.message, contains('/users'));
    });

    test('logs response with status code on onResponse', () {
      final options = RequestOptions(path: 'https://api.test/users');
      interceptor.onRequest(options, _FakeRequestHandler());

      final response = Response<dynamic>(
        requestOptions: options,
        statusCode: 200,
        data: {'ok': true},
      );
      final handler = _FakeResponseHandler();
      interceptor.onResponse(response, handler);

      expect(handler.called, isTrue);
      expect(memory.records.last.message, contains('200'));
    });

    test('logs error on onError', () {
      final options = RequestOptions(path: 'https://api.test/fail');
      final err = DioException(
        requestOptions: options,
        message: 'timeout',
        type: DioExceptionType.connectionTimeout,
      );
      final handler = _FakeErrorHandler();
      interceptor.onError(err, handler);

      expect(handler.called, isTrue);
      expect(memory.records.last.level, TraceLevel.error);
      expect(memory.records.last.message, contains('HTTP error'));
    });

    test('redacts authorization header in request context', () {
      final options = RequestOptions(
        path: 'https://api.test/secure',
        headers: {'Authorization': 'Bearer secret-token'},
      );
      interceptor.onRequest(options, _FakeRequestHandler());

      final context = memory.records.first.context;
      final headers = context['headers'] as Map<String, dynamic>;
      expect(headers['Authorization'], '***REDACTED***');
    });

    test('redacts sensitive body keys', () {
      final options = RequestOptions(
        path: 'https://api.test/login',
        data: {'username': 'alice', 'password': 'secret'},
      );
      interceptor.onRequest(options, _FakeRequestHandler());

      final body = memory.records.first.context['body'] as Map<String, dynamic>;
      expect(body['username'], 'alice');
      expect(body['password'], '***REDACTED***');
    });
  });
}

class _FakeRequestHandler extends RequestInterceptorHandler {
  bool called = false;

  @override
  void next(RequestOptions options) => called = true;
}

class _FakeResponseHandler extends ResponseInterceptorHandler {
  bool called = false;

  @override
  void next(Response<dynamic> response) => called = true;
}

class _FakeErrorHandler extends ErrorInterceptorHandler {
  bool called = false;

  @override
  void next(DioException err) => called = true;
}
