import 'package:dev_libraries/contracts/databasecontext.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

abstract class SqlDatabaseContext extends DatabaseContext {
  Database? _database;

  void Function(Database db, int version) get onDatabaseCreated;

  Database Function(Database db) get onDatabaseInitialized;

  SqlDatabaseContext(int version) : super(version);

  Future<void> initialize() async =>
      await _getDatabasePath().then((value) async {
        _database = await _initDatabaseInstance().then(onDatabaseInitialized);
      });

  Future<void> dispose() => _initDatabaseInstance()
      .then((db) => db.close())
      .then((_) => _database = null);

  Future<void> dropDatabase() async =>
      _getDatabasePath().then((path) => deleteDatabase(path));

  Future<String> _getDatabasePath() async {
    if (databasePath != null && databasePath!.isNotEmpty) return databasePath!;

    databasePath = await getDatabasesPath()
        .then((path) => databasePath = join(path, "$databaseName.db"));

    return databasePath!;
  }

  Future<Database> _initDatabaseInstance() async {
    if (_database != null) return _database!;

    return _getDatabasePath().then((path) =>
        openDatabase(path, onCreate: onDatabaseCreated, version: version));
  }
}
