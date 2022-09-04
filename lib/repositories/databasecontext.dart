import 'package:dev_libraries/contracts/databasecontext.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

abstract class SqlDatabaseContext extends DatabaseContext {
  Database? _database;

  void Function(Database db, int version) get onDatabaseCreated;

  Database Function(Database db) get onDatabaseInitialized;

  Future<void> initialize() async {
    databasePath =
        await getDatabasesPath().then((path) => join(path, databaseName));

    _database = await _initDatabaseInstance().then(onDatabaseInitialized);
  }

  Future<void> dispose() => _initDatabaseInstance()
      .then((db) => db.close())
      .then((_) => _database = null);

  Future<void> dropDatabase() async =>
      _getDatabasePath().then((path) => deleteDatabase(path));

  Future<String> _getDatabasePath() async => getDatabasesPath()
      .then((path) => databasePath = join(path, databaseName));

  Future<Database> _initDatabaseInstance() async {
    if (_database != null) return _database!;

    return _getDatabasePath().then((path) =>
        openDatabase(path, onCreate: onDatabaseCreated, version: version));
  }
}
