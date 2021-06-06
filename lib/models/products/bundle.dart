import 'dart:collection';

import 'package:dev_libraries/models/products/product.dart';

class Bundle extends Product {
  final UnmodifiableListView<Product> items;
  
  const Bundle(String id, String name, String description, double price, this.items) 
  : super(id, name, description, price);

  @override
  List<Object> get props => [id, name, description, items];

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'currencyCode': currencyCode
  };

  @override
  String toString() => 'Bundle { id: $id, name:$name, description: $description }';

}