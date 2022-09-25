abstract class DatabaseContext {
  String get databaseName;
  late int version;

  late String databasePath;

  Future<void> initialize();

  Future<void> dispose();

  Future<void> dropDatabase();
}