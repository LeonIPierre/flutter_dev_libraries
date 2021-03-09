import 'package:dev_libraries/models/products/product.dart';
import 'package:equatable/equatable.dart';

enum PurhaseState {
  Any,

  Purchased,

  Voided,

  Active,

  Cancelled,

  InGracePeriod,

  OnHold,

  Paused,

  Expired
}

class Purchase extends Equatable {
  final String id;

  final Product product;

  final DateTime timestamp;

  const Purchase(this.id, this.product, this.timestamp);

  @override
  List<Object> get props => [id, product, timestamp];

  Map<String, dynamic> toJson() =>
      {'id': id, 'product': product.toJson(), 'timestamp': timestamp};

  @override
  String toString() =>
      'Purchase { id: $id, product:$product, timestamp:$timestamp }';
}
