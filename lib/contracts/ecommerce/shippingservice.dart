import 'dart:collection';

import 'package:dev_libraries/models/address.dart';
import 'package:dev_libraries/models/ecommerce/deliverystatus.dart';
import 'package:dev_libraries/models/ecommerce/location.dart';
import 'package:dev_libraries/models/products/product.dart';

abstract class ShippingService {
  Future<double> getEstimate(Address from, Address to);

  Future<void> deliver(Iterable<Product> items, Location to, { Location from });

  Future<Iterable<DeliveryStatus>> getDeliveryStatus(Iterable<Product> items);
}