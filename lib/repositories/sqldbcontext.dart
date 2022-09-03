import 'package:dev_libraries/dev_libraries.dart';
import 'package:sqflite/sqflite.dart';

typedef EntityFromMapCreator<T> = T Function(Map<String, Object?> map);

typedef EntityToMapCreator<T> = Map<String, Object?> Function(T entity);

abstract class SqlDbContext<T extends PrimaryKeyIdentifier>
    extends RepositoryContext<T, int> {
  final Database database;

  final EntityToMapCreator<T> entityToMapCreator;

  final EntityFromMapCreator<T> entityFromMapCreator;

  SqlDbContext(
      this.database, this.entityFromMapCreator, this.entityToMapCreator);

  @override
  Future<int> add(T entity) =>
      database.insert(tableName, entityToMapCreator(entity));

  @override
  Future<int> addAll(Iterable<T> entities) =>
      database.transaction((transaction) async {
        final Batch batch = transaction.batch();

        for (final entity in entities) {
          batch.insert(tableName, entityToMapCreator(entity));
        }

        return batch.commit().then((insertedIds) => insertedIds.length);
      });

  @override
  Future<int> delete(T entity) =>
      database.delete(tableName, where: 'id = ?', whereArgs: [entity.id]);

  @override
  Future<T> get(String id) => database.query(tableName,
      where: 'id = ?',
      whereArgs: [id]).then((result) => entityFromMapCreator(result.first));

  @override
  Future<Iterable<T>> getAll(Iterable<T> entities) {
    var entityIds = entities.map((e) => e.id);
    return database.query(tableName,
        where: 'id IN (${entityIds.join(',')})',
        whereArgs: [
          entityIds
        ]).then((result) => result.map((e) => entityFromMapCreator(e)));
  }

  @override
  Future<int> update(T entity) =>
      database.update(tableName, entityToMapCreator(entity),
          where: 'id = ?', whereArgs: [entity.id]);
}
