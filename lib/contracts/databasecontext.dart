abstract class DatabaseContext {
  String get databaseName;
  String? databasePath;
  int version;

  DatabaseContext(this.version);

  Future<void> initialize();

  Future<void> dispose();

  Future<void> dropDatabase();
}
