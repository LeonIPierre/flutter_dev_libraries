import 'package:dev_libraries/dev_libraries.dart';
import 'package:sqflite/sqflite.dart';

typedef EntityFromMapCreator<T> = T Function(Map<String, Object?> map);

typedef EntityToMapCreator<T> = Map<String, Object?> Function(T entity);

abstract class SqlDbContext<T extends PrimaryKeyIdentifier>
    extends RepositoryContext<T, int> {
  final Database _database;

  final EntityToMapCreator _entityToMapCreator;

  final EntityFromMapCreator _entityFromMapCreator;

  SqlDbContext(
      this._database, this._entityFromMapCreator, this._entityToMapCreator);

  @override
  Future<int> add(T entity) =>
      _database.insert(tableName, _entityToMapCreator(entity));

  @override
  Future<int> addAll(Iterable<T> entities) =>
      _database.transaction((transaction) async {
        final Batch batch = transaction.batch();

        for (final entity in entities) {
          batch.insert(tableName, _entityToMapCreator(entity));
        }

        return batch.commit().then((insertedIds) => insertedIds.length);
      });

  @override
  Future<int> delete(T entity) =>
      _database.delete(tableName, where: 'id = ?', whereArgs: [entity.id]);

  @override
  Future<T> get(String id) => _database.query(tableName,
      where: 'id = ?',
      whereArgs: [id]).then((result) => _entityFromMapCreator(result.first));

  @override
  Future<Iterable<T>> getAll(Iterable<T> entities) {
    var entityIds = entities.map((e) => e.id);
    return _database.query(tableName,
        where: 'id IN (${entityIds.join(',')})',
        whereArgs: [
          entityIds
        ]).then((result) => result.map((e) => _entityFromMapCreator(e)));
  }

  @override
  Future<int> update(T entity) =>
      _database.update(tableName, _entityToMapCreator(entity),
          where: 'id = ?', whereArgs: [entity.id]);
}
