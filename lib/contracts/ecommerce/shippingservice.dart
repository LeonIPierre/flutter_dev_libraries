import 'package:dev_libraries/models/address.dart';
import 'package:dev_libraries/models/ecommerce/location.dart';
import 'package:dev_libraries/models/products/product.dart';

abstract class ShippingService {
  Future<double> getEstimate(Address from, Address to);

  Future<void> deliver(List<Product> items, Location from, Location to);
}