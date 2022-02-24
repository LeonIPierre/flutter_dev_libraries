
abstract class RepositoryBase<T, U> {
  String get tableName;
  
  Future<Iterable<T>> getAll();

  Future<T> get(String id);

  Future<U> add(T entity);

  Future<U> addAll(Iterable<T> entiites);

  Future<U> update(T entity);

  Future<U> delete(T entity);

  // ignore: unused_element
  Map<String, Object?> _toMap(T item);
}