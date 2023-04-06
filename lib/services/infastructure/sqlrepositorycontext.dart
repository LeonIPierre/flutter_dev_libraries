
import 'package:dev_libraries/contracts/infastructure/repositorycontext.dart';
import 'package:dev_libraries/services/infastructure/sqldatabasecontext.dart';
import 'package:sqflite/sqflite.dart';

abstract class SqlRepositoryContext<T extends PrimaryKeyIdentifier?>
    extends RepositoryContext<T, int> {
  String get tableName;

  final SqlDatabaseContext databaseContext;

  final T Function(Map<String, Object?> map) entityFromMapCreator;

  final Map<String, Object?> Function(T entity) entityToMapCreator;

  SqlRepositoryContext(
      this.databaseContext, this.entityFromMapCreator, this.entityToMapCreator);

  @override
  Future<int> add(T entity) =>
      databaseContext.database.insert(tableName, entityToMapCreator(entity).convertDateTimesToInt());

  @override
  Future<int> addAll(Iterable<T> entities) =>
      databaseContext.database.transaction((transaction) async {
        final Batch batch = transaction.batch();

        for (final entity in entities) {
          batch.insert(tableName, entityToMapCreator(entity).convertDateTimesToInt());
        }

        return batch.commit().then((insertedIds) => insertedIds.length);
      });

  @override
  Future<int> delete(T entity) =>
      databaseContext.database.delete(tableName, where: 'id = ?', whereArgs: [entity!.id]);

  @override
  Future<T> get(PrimaryKeyIdentifier entityIdentifier) => databaseContext.database.query(tableName,
      where: 'id = ?',
      whereArgs: [entityIdentifier.id]).then((result) => entityFromMapCreator(result.single));

  @override
  Future<Iterable<T>> getAll({Iterable<T>? entities}) {
    if (entities == null)
      return databaseContext.database
          .query(tableName)
          .then((results) => results.map((e) => entityFromMapCreator(e)));

    final entityIds = entities.map((e) => e!.id);
    return databaseContext.database.query(tableName,
        where: 'id IN (${entityIds.map((e) => '?').join(',')})',
        whereArgs: entityIds.toList())
      .then((result) => result.map((e) => entityFromMapCreator(e)));
  }

  @override
  Future<int> update(T entity) =>
      databaseContext.database.update(tableName, entityToMapCreator(entity).convertDateTimesToInt(),
          where: 'id = ?', whereArgs: [entity!.id]);
}

extension SqlDbContextMapExtensions on Map<String, dynamic> {
  Map<String, dynamic> convertToDateTime(String datePattern) {

    forEach((key, value) {
      if(RegExp(datePattern).hasMatch(key))
        this.update(key, (value) => DateTime.fromMicrosecondsSinceEpoch(int.parse(value.toString())));
    });

    return this;
  }

  Map<String, dynamic> convertDateTimesToInt() {
    forEach((key, value) {
      if(value.runtimeType == DateTime)
        this.update(key, (value) => (value as DateTime).microsecondsSinceEpoch);
    });

    return this;
  }
}