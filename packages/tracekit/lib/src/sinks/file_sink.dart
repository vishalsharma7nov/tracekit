import 'dart:io';

import '../models/log_record.dart';
import '../models/trace_level.dart';
import '../formatters/formatter.dart';
import '../formatters/json_formatter.dart';
import 'sink.dart';

/// Appends formatted logs to a file with optional rotation.
class FileSink extends TraceSink {
  /// Creates a [FileSink].
  FileSink({
    required this.file,
    this.minLevel = TraceLevel.debug,
    TraceFormatter? formatter,
    this.maxFileSizeBytes = 5 * 1024 * 1024,
    this.maxBackupFiles = 3,
  }) : formatter = formatter ?? const JsonFormatter();

  /// Target log file.
  final File file;

  @override
  final TraceLevel minLevel;

  @override
  final TraceFormatter formatter;

  /// Rotate when file exceeds this size.
  final int maxFileSizeBytes;

  /// Number of rotated backup files to keep.
  final int maxBackupFiles;

  IOSink? _sink;

  /// Opens the file for appending.
  Future<void> open() async {
    if (!file.parent.existsSync()) {
      await file.parent.create(recursive: true);
    }
    _sink = file.openWrite(mode: FileMode.append);
  }

  @override
  void write(LogRecord record) {
    try {
      _rotateIfNeeded();
      _sink ??= file.openWrite(mode: FileMode.append);
      _sink!.writeln(formatter.format(record));
    } on Object {
      // Silent failure — logging must not crash the app.
    }
  }

  void _rotateIfNeeded() {
    if (!file.existsSync()) {
      return;
    }
    if (file.lengthSync() < maxFileSizeBytes) {
      return;
    }
    _sink?.close();
    _sink = null;
    for (var i = maxBackupFiles - 1; i >= 1; i--) {
      final src = File('${file.path}.$i');
      if (src.existsSync()) {
        src.renameSync('${file.path}.${i + 1}');
      }
    }
    if (file.existsSync()) {
      file.renameSync('${file.path}.1');
    }
  }

  @override
  Future<void> flush() async {
    await _sink?.flush();
  }

  @override
  Future<void> dispose() async {
    await _sink?.close();
    _sink = null;
  }
}
