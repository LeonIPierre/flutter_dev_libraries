import 'package:dev_libraries/models/products/product.dart';

abstract class ProductService {
  Future<Iterable<Product>> getAll();

  Future<Iterable<Product>> getProducts(Iterable<String> ids);

  Future<Product> getProduct(String id);
}