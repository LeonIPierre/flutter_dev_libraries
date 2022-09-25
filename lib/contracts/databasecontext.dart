abstract class DatabaseContext {
  String get databaseName;
  late int version;

  String? databasePath;

  Future<void> initialize();

  Future<void> dispose();

  Future<void> dropDatabase();
}
