
abstract class RepositoryContext<T extends PrimaryKeyIdentifier, U> {
  String get tableName;
  
  Future<U> add(T entity);

  Future<U> addAll(Iterable<T> entities);

  Future<U> delete(T entity);

  Future<T> get(String id);

  Future<Iterable<T>> getAll(Iterable<T> entities);

  Future<U> update(T entity);
}

abstract class PrimaryKeyIdentifier {
  String get id;
}