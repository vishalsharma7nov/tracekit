import 'console_writer.dart';

/// Creates the platform [ConsoleWriter] implementation.
ConsoleWriter createConsoleWriter() => throw UnsupportedError(
      'Cannot create ConsoleWriter without dart:io or web implementation.',
    );
