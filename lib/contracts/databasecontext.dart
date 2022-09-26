abstract class DatabaseContext {
  String get databaseName;
  int get version;
  String? databasePath;
  
  Future<void> initialize();

  Future<void> dispose();

  Future<void> dropDatabase();
}
