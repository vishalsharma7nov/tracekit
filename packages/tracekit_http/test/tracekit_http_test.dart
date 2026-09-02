import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:tracekit/tracekit.dart';
import 'package:tracekit_http/tracekit_http.dart';

void main() {
  late MemorySink memory;
  late TraceKitHttpClient client;

  setUp(() async {
    TraceKit.reset();
    memory = MemorySink();
    await TraceKit.init(
      TraceConfig(sinks: [memory], captureCallerInfo: false),
    );
    client = TraceKitHttpClient(inner: _MockClient());
  });

  tearDown(() {
    client.close();
    TraceKit.reset();
  });

  group('TraceKitHttpClient', () {
    test('logs request and response on successful send', () async {
      final request = http.Request('GET', Uri.parse('https://api.test/data'));
      final response = await client.send(request);
      await response.stream.drain<void>();

      expect(memory.records, hasLength(2));
      expect(memory.records.first.message, contains('GET'));
      expect(memory.records.last.message, contains('200'));
    });

    test('logs error when inner client throws', () async {
      client.close();
      client = TraceKitHttpClient(inner: _MockClient(shouldFail: true));
      final request = http.Request('GET', Uri.parse('https://api.test/fail'));

      await expectLater(client.send(request), throwsA(isA<Exception>()));
      expect(memory.records.last.level, TraceLevel.error);
      expect(memory.records.last.message, contains('HTTP error'));
    });

    test('redacts authorization header', () async {
      final request = http.Request('GET', Uri.parse('https://api.test/data'));
      request.headers['Authorization'] = 'Bearer secret';
      final response = await client.send(request);
      await response.stream.drain<void>();

      final headers = memory.records.first.context['headers'] as Map<String, String>;
      expect(headers['Authorization'], '***REDACTED***');
    });
  });
}

class _MockClient extends http.BaseClient {
  _MockClient({this.shouldFail = false});

  final bool shouldFail;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (shouldFail) {
      throw Exception('network failure');
    }
    return http.StreamedResponse(
      Stream.value(<int>[]),
      200,
      request: request,
    );
  }
}
