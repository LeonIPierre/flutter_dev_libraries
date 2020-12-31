import 'package:dev_libraries/models/payment.dart';
import 'package:dev_libraries/models/products/product.dart';

class Receipt {
  final String id;
  final Product product;
  final PaymentStatus status;
  final Object data;

  Receipt(this.id, this.product, this.status, { this.data });
}