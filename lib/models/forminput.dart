import 'package:equatable/equatable.dart';

class FormInput<T> extends Equatable {
  final String id;
  final String type;
  final String name;
  final T? value;

  const FormInput(this.id, this.type, this.name, {this.value});

  FormInput clone(T value) => FormInput(this.id, this.type, this.name, value: value);

  @override
  List<Object?> get props => [id, type, name, value];

  @override
  String toString() => 'FormInput { id: $id, type: $type, name: $name, value: $value }';
}