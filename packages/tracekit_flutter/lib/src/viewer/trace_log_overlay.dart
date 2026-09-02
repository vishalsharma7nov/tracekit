import 'package:flutter/material.dart';
import 'package:tracekit/tracekit.dart';

import 'trace_log_viewer.dart';

/// Floating debug button that opens the log viewer.
class TraceLogOverlay extends StatefulWidget {
  /// Creates a [TraceLogOverlay] wrapping [child].
  const TraceLogOverlay({
    required this.child,
    required this.memorySink,
    super.key,
  });

  /// App content.
  final Widget child;

  /// Memory sink to display.
  final MemorySink memorySink;

  @override
  State<TraceLogOverlay> createState() => _TraceLogOverlayState();
}

class _TraceLogOverlayState extends State<TraceLogOverlay> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.small(
            heroTag: 'tracekit_log_viewer',
            onPressed: _openViewer,
            child: const Icon(Icons.list_alt),
          ),
        ),
      ],
    );
  }

  void _openViewer() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TraceLogViewer(sink: widget.memorySink),
      ),
    );
  }
}
