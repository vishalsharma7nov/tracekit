import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tracekit/tracekit.dart';

import '../export/log_exporter.dart';

/// In-app scrollable log viewer with search, filter, and export.
class TraceLogViewer extends StatefulWidget {
  /// Creates a [TraceLogViewer].
  const TraceLogViewer({
    required this.sink,
    super.key,
  });

  /// Memory sink to display.
  final MemorySink sink;

  @override
  State<TraceLogViewer> createState() => _TraceLogViewerState();
}

class _TraceLogViewerState extends State<TraceLogViewer> {
  String _query = '';
  TraceLevel? _levelFilter;

  @override
  Widget build(BuildContext context) {
    final records = _filteredRecords;
    return Scaffold(
      appBar: AppBar(
        title: const Text('TraceKit Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => LogExporter(widget.sink).share(),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              widget.sink.clear();
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search logs...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _levelFilter == null,
                  onSelected: (_) => setState(() => _levelFilter = null),
                ),
                for (final level in TraceLevel.values)
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: FilterChip(
                      label: Text(level.label),
                      selected: _levelFilter == level,
                      onSelected: (_) => setState(() => _levelFilter = level),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: records.length,
              reverse: true,
              itemBuilder: (context, index) {
                final record = records[records.length - 1 - index];
                return _LogTile(record: record);
              },
            ),
          ),
        ],
      ),
    );
  }

  List<LogRecord> get _filteredRecords {
    return widget.sink.records.where((record) {
      if (_levelFilter != null && record.level != _levelFilter) {
        return false;
      }
      if (_query.isEmpty) {
        return true;
      }
      final haystack = [
        record.message,
        record.tag,
        record.caller?.locationLabel,
        record.context.toString(),
      ].whereType<String>().join(' ').toLowerCase();
      return haystack.contains(_query);
    }).toList();
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({required this.record});

  final LogRecord record;

  Color _colorForLevel(TraceLevel level) {
    switch (level) {
      case TraceLevel.trace:
      case TraceLevel.debug:
        return Colors.blueGrey;
      case TraceLevel.info:
        return Colors.blue;
      case TraceLevel.warn:
        return Colors.orange;
      case TraceLevel.error:
      case TraceLevel.fatal:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final caller = record.caller?.locationLabel;
    return ExpansionTile(
      leading:
          Icon(Icons.circle, size: 12, color: _colorForLevel(record.level)),
      title: Text(
        record.message,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        [
          record.level.label,
          if (record.tag != null) record.tag,
          if (caller != null) caller,
        ].join(' · '),
      ),
      children: [
        if (record.context.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(record.context.toString()),
          ),
        if (record.error != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(record.error.toString()),
          ),
        TextButton.icon(
          onPressed: () {
            final text = caller ?? record.message;
            Clipboard.setData(ClipboardData(text: text));
          },
          icon: const Icon(Icons.copy, size: 16),
          label: const Text('Copy location'),
        ),
      ],
    );
  }
}
