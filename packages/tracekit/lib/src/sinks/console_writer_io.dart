import 'dart:io';

import 'console_writer.dart';

/// VM/desktop/mobile console writer using stdout/stderr.
class IoConsoleWriter implements ConsoleWriter {
  @override
  void write(String message) {
    stdout.writeln(message);
  }

  @override
  void writeError(String message) {
    stderr.writeln(message);
  }
}

ConsoleWriter createConsoleWriter() => IoConsoleWriter();
