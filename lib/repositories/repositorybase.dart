
abstract class RepositoryBase<T, U> {
  String get tableName;
  
  Future<U> add(T entity);

  Future<U> addAll(Iterable<T> entities);

  Future<U> delete(T entity);

  Future<T> get(String id);

  Future<Iterable<T>> getAll();

  Future<U> update(T entity);

  Map<String, Object?> toMap(T entity);
}