import 'dart:collection';

import 'package:dev_libraries/models/address.dart';
import 'package:dev_libraries/models/ecommerce/deliverystatus.dart';
import 'package:dev_libraries/models/ecommerce/location.dart';
import 'package:dev_libraries/models/products/product.dart';

abstract class ShippingService {
  Future<double> getEstimate(Address from, Address to);

  Future<void> deliver(List<Product> items, Location to, { Location from });

  Future<UnmodifiableListView<DeliveryStatus>> getDeliveryStatus(List<Product> items);
}