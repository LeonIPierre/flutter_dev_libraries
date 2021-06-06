import 'package:dev_libraries/models/ecommerce/location.dart';
import 'package:dev_libraries/models/products/product.dart';

class OrderRequest {
  final Location pickupLocation;

  final Location? dropoffLocation;

  final List<Product> items;

  OrderRequest(this.items, this.pickupLocation, {this.dropoffLocation});

  Map<String, dynamic> toJson() => {
    'pickup': pickupLocation.toJson(),
    'dropoff': dropoffLocation?.toJson(),
    'items': items.map((i) => i.toJson()).toList()
  };

  @override
  String toString() => 'OrderRequest { pickup:$pickupLocation, dropoff:$dropoffLocation, items:$items }';
}