import 'dart:collection';

import 'package:dev_libraries/models/products/product.dart';
import 'package:dev_libraries/models/products/receipt.dart';

enum PaymentStatus {
  None,
  Started,
  Cancelled,
  Error,
  Completed
}

enum PaymentOption
{
  GooglePay,
  ApplePay,
  Stripe,
  PayPal
}

abstract class PaymentService {
  Stream<UnmodifiableListView<Receipt>> get purchases;

  Future<void> pay(PaymentOption paymentOption, UnmodifiableListView<Product> products);

  Future<void> completePayment(Receipt product);

  Future<void> completeAllPayments(UnmodifiableListView<Receipt> products);

  Future<UnmodifiableListView<Receipt>> getStoreProductsAsync(UnmodifiableListView<String> productIds);
}