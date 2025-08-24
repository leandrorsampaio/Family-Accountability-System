import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  // Debug level logging
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  // Info level logging
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  // Warning level logging
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  // Error level logging
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  // Fatal level logging
  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  // Database specific logging
  static void database(String operation, String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i('🗄️ DB $operation: $message', error: error, stackTrace: stackTrace);
  }

  // UI specific logging
  static void ui(String component, String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d('🖼️ UI $component: $message', error: error, stackTrace: stackTrace);
  }

  // Authentication specific logging
  static void auth(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i('🔐 AUTH: $message', error: error, stackTrace: stackTrace);
  }
}