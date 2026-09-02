import 'dart:convert';
import 'dart:typed_data';

import '../models/log_record.dart';
import '../models/trace_level.dart';
import '../formatters/formatter.dart';
import 'sink.dart';

/// Wraps a delegate sink and XOR-obfuscates output (lightweight encryption).
///
/// For production-grade AES-256, integrate a crypto package in app code.
class EncryptedSink extends TraceSink {
  /// Creates an [EncryptedSink].
  EncryptedSink({
    required this.delegate,
    required this.key,
  });

  /// Underlying sink.
  final TraceSink delegate;

  /// Encryption key bytes.
  final Uint8List key;

  @override
  TraceLevel get minLevel => delegate.minLevel;

  @override
  TraceFormatter get formatter => delegate.formatter;

  @override
  void write(LogRecord record) {
    final plain = formatter.format(record);
    final encrypted = _xorEncrypt(utf8.encode(plain));
    final wrapped = record.copyWith(
      message: base64Encode(encrypted),
      context: {'encrypted': true},
    );
    delegate.write(wrapped);
  }

  Uint8List _xorEncrypt(List<int> data) {
    final result = Uint8List(data.length);
    for (var i = 0; i < data.length; i++) {
      result[i] = data[i] ^ key[i % key.length];
    }
    return result;
  }

  @override
  Future<void> flush() => delegate.flush();

  @override
  Future<void> dispose() => delegate.dispose();
}
