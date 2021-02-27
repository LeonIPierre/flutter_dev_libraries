
import 'dart:collection';

import 'package:dev_libraries/models/creditcard.dart';
import 'package:dev_libraries/models/payment.dart';
import 'package:dev_libraries/models/products/product.dart';

abstract class PaymentService {
  Stream<UnmodifiableListView<PaymentResult>> get purchases;

  Future<void> pay(PaymentOption paymentOption, UnmodifiableListView<Product> products);

  Future<void> payWithCreditCard(CreditCard creditCard, UnmodifiableListView<Product> products);

  Future<PaymentResult> completePayment(PaymentResult payment);

  Future<UnmodifiableListView<PaymentResult>> completeAllPayments(UnmodifiableListView<PaymentResult> payments);

  Future<UnmodifiableListView<Product>> getStoreProductsAsync(UnmodifiableListView<Product> products);
}
