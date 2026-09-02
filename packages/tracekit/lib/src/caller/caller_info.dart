/// Source location and member name for a log call site.
class CallerInfo {
  /// Creates [CallerInfo] with required [file] and [line].
  const CallerInfo({
    required this.file,
    required this.line,
    this.column,
    this.member,
    this.package,
  });

  /// Creates caller info from explicit values (wrapper override).
  factory CallerInfo.manual(
    String file,
    int line, {
    int? column,
    String? member,
    String? package,
  }) {
    return CallerInfo(
      file: file,
      line: line,
      column: column,
      member: member,
      package: package,
    );
  }

  /// Captures compile-time location from the caller's library.
  ///
  /// Must be invoked inline at the call site in application code:
  /// `Trace.info('msg', caller: CallerInfo.here())`.
  factory CallerInfo.here([
    Object? file = #file,
    Object? line = #line,
    Object? column = #column,
  ]) {
    return CallerInfo(
      file: file.toString(),
      line: line as int,
      column: column as int?,
    );
  }

  /// Source file path or URI.
  final String file;

  /// Line number in [file].
  final int line;

  /// Optional column number.
  final int? column;

  /// Method or function name, when available from stack frames.
  final String? member;

  /// Package name extracted from the URI, when available.
  final String? package;

  /// Short display label such as `auth_service.dart:42`.
  String get locationLabel {
    final name = file.split('/').last;
    return '$name:$line';
  }

  /// Serializes to JSON.
  Map<String, Object?> toJson() => {
        'file': file,
        'line': line,
        if (column != null) 'column': column,
        if (member != null) 'member': member,
        if (package != null) 'package': package,
      };

  @override
  String toString() {
    final memberPart = member != null ? ' · $member' : '';
    return '$locationLabel$memberPart';
  }
}
