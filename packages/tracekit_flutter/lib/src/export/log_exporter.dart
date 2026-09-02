import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tracekit/tracekit.dart';

/// Exports in-memory logs for sharing or saving.
class LogExporter {
  /// Creates a [LogExporter] for [sink].
  const LogExporter(this.sink);

  /// Source memory sink.
  final MemorySink sink;

  /// Returns logs as a JSON string.
  String exportAsJson() {
    final records = sink.records.map((r) => r.toJson()).toList();
    return const JsonEncoder.withIndent('  ').convert(records);
  }

  /// Returns logs as plain text lines.
  String exportAsText() {
    const formatter = PrettyFormatter(includeTimestamp: true);
    return sink.records.map(formatter.format).join('\n');
  }

  /// Opens the platform share sheet with log contents.
  Future<void> share({String filename = 'tracekit_logs.txt'}) async {
    await Share.share(exportAsText(), subject: filename);
  }

  /// Copies export text to the clipboard.
  Future<void> copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: exportAsText()));
  }
}
