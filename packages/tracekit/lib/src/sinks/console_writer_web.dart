import 'dart:js_interop';

import 'console_writer.dart';

@JS('console.log')
external void _consoleLog(JSString message);

@JS('console.error')
external void _consoleError(JSString message);

/// Web console writer using the browser console API.
class WebConsoleWriter implements ConsoleWriter {
  @override
  void write(String message) {
    _consoleLog(message.toJS);
  }

  @override
  void writeError(String message) {
    _consoleError(message.toJS);
  }
}

ConsoleWriter createConsoleWriter() => WebConsoleWriter();
