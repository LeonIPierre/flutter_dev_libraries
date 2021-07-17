import 'dart:collection';

abstract class RepositoryBase<T, U> {
  Future<UnmodifiableListView<T>> getAll();

  Future<U> get(String id);

  Future<U> add(T item);

  Future<U> update(T item);

  Future<U> delete(T item);
}