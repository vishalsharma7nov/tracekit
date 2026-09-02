import 'package:stack_trace/stack_trace.dart';

import 'caller_info.dart';
import 'caller_info_config.dart';

/// Resolves [CallerInfo] from a [StackTrace], skipping internal frames.
class CallerResolver {
  /// Creates a [CallerResolver].
  const CallerResolver({
    this.skipPackagePrefixes = CallerInfoConfig.defaultSkipPrefixes,
    this.stackFramesToSkip = 1,
  });

  /// Prefixes for frames that should be skipped.
  final List<String> skipPackagePrefixes;

  /// Additional frames to skip from the top of the parsed trace.
  final int stackFramesToSkip;

  /// Resolves caller info from [stackTrace], or null if none found.
  CallerInfo? resolve(StackTrace stackTrace) {
    final trace = Trace.from(stackTrace);
    final frames = trace.frames;
    var skipped = 0;

    for (final frame in frames) {
      final uri = frame.uri;
      if (_shouldSkip(uri.toString())) {
        continue;
      }
      if (skipped < stackFramesToSkip) {
        skipped++;
        continue;
      }

      final package = _extractPackage(uri.toString());
      return CallerInfo(
        file: uri.path.isNotEmpty ? uri.path : uri.toString(),
        line: frame.line ?? 0,
        column: frame.column,
        member: frame.member,
        package: package,
      );
    }
    return null;
  }

  bool _shouldSkip(String uri) {
    for (final prefix in skipPackagePrefixes) {
      if (uri.startsWith(prefix)) {
        return true;
      }
    }
    return false;
  }

  String? _extractPackage(String uri) {
    const prefix = 'package:';
    if (!uri.startsWith(prefix)) {
      return null;
    }
    final rest = uri.substring(prefix.length);
    final slash = rest.indexOf('/');
    if (slash == -1) {
      return rest;
    }
    return rest.substring(0, slash);
  }
}
