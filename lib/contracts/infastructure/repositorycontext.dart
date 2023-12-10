
import 'package:equatable/equatable.dart';

abstract class RepositoryContext<T extends PrimaryKeyIdentifier?, U> {  
  Future<U> add(T entity);

  Future<U> addAll(Iterable<T> entities);

  Future<U> delete(T entity);

  Future<T> get(PrimaryKeyIdentifier entityIdentifier);

  Future<Iterable<T>> getAll({Iterable<T>? entities});

  Future<U> update(T entity);
}

abstract class PrimaryKeyIdentifier with EquatableMixin {
  String get id;

  @override
  List<Object?> get props => [id];
}

mixin PrimaryKeyIdentifierMixin on PrimaryKeyIdentifier {}