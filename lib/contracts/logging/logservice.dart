enum LogLevel {
  Info,
  Log,
  Warn,
  Debug,
  Error,
  Fatal
}

abstract class LogService {
  void initialize();
  
  void log(LogLevel level, Exception exception, String message);
}