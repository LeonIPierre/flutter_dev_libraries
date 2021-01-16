import 'package:equatable/equatable.dart';

class Product  extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currencyCode;

  Product(this.id, this.name, this.description, this.price, { this.currencyCode = "USD" });

  @override
  List<Object> get props => [id, name, description, price];
}