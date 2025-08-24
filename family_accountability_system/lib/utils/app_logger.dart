import 'package:logger/logger.dart';

// In-memory logger for displaying logs in the app
class InMemoryLogger {
  static final List<String> _logs = [];
  static const int maxLogs = 1000; // Keep last 1000 log entries

  static void addLog(String message) {
    final timestamp = DateTime.now().toString().substring(11, 19);
    final logEntry = '[$timestamp] $message';
    _logs.add(logEntry);
    
    // Keep only the last maxLogs entries
    if (_logs.length > maxLogs) {
      _logs.removeAt(0);
    }
  }

  static List<String> getLogs() => List.unmodifiable(_logs);
  static void clearLogs() => _logs.clear();
}

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
    final logMsg = 'DEBUG: $message${error != null ? ' - Error: $error' : ''}';
    InMemoryLogger.addLog(logMsg);
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  // Info level logging
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    final logMsg = 'INFO: $message${error != null ? ' - Error: $error' : ''}';
    InMemoryLogger.addLog(logMsg);
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  // Warning level logging
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    final logMsg = '⚠️ WARNING: $message${error != null ? ' - Error: $error' : ''}';
    InMemoryLogger.addLog(logMsg);
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  // Error level logging
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    final logMsg = '🚨 ERROR: $message${error != null ? ' - Error: $error' : ''}';
    InMemoryLogger.addLog(logMsg);
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  // Fatal level logging
  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    final logMsg = '💀 FATAL: $message${error != null ? ' - Error: $error' : ''}';
    InMemoryLogger.addLog(logMsg);
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  // Database specific logging
  static void database(String operation, String message, [dynamic error, StackTrace? stackTrace]) {
    final logMsg = '🗄️ DB $operation: $message${error != null ? ' - Error: $error' : ''}';
    InMemoryLogger.addLog(logMsg);
    _logger.i('🗄️ DB $operation: $message', error: error, stackTrace: stackTrace);
  }

  // UI specific logging
  static void ui(String component, String message, [dynamic error, StackTrace? stackTrace]) {
    final logMsg = '🖼️ UI $component: $message${error != null ? ' - Error: $error' : ''}';
    InMemoryLogger.addLog(logMsg);
    _logger.d('🖼️ UI $component: $message', error: error, stackTrace: stackTrace);
  }

  // Authentication specific logging
  static void auth(String message, [dynamic error, StackTrace? stackTrace]) {
    final logMsg = '🔐 AUTH: $message${error != null ? ' - Error: $error' : ''}';
    InMemoryLogger.addLog(logMsg);
    _logger.i('🔐 AUTH: $message', error: error, stackTrace: stackTrace);
  }
}