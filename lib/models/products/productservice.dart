import 'dart:collection';

import 'package:dev_libraries/models/products/product.dart';

abstract class ProductService {
  Future<UnmodifiableListView<Product>> getAll();

  Future<List<Product>> getProducts(List<String> ids);

  Future<Product> getProduct(String id);
}