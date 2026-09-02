/// Writes text to the platform console without using print/log/debugPrint.
abstract class ConsoleWriter {
  /// Writes [message] to standard output.
  void write(String message);

  /// Writes [message] to standard error.
  void writeError(String message);
}
