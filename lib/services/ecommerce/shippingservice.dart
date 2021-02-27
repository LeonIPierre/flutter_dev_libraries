import 'package:dev_libraries/models/address.dart';
import 'package:dev_libraries/models/ecommerce/location.dart';
import 'package:dev_libraries/models/products/product.dart';

abstract class ShippingService {
  Future<double> getEstimate(Address address);

  Future<void> deliver(List<Product> items, Location from, Location to);
}