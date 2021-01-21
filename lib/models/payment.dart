import 'dart:collection';

import 'package:dev_libraries/models/products/product.dart';

import 'creditcard.dart';

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
  CreditCard,
  PayPal
}

abstract class PaymentService {
  Stream<UnmodifiableListView<PaymentResult>> get purchases;

  Future<void> pay(PaymentOption paymentOption, UnmodifiableListView<Product> products);

  Future<void> payWithCreditCard(CreditCard creditCard, UnmodifiableListView<Product> products);

  Future<PaymentResult> completePayment(PaymentResult payment);

  Future<UnmodifiableListView<PaymentResult>> completeAllPayments(UnmodifiableListView<PaymentResult> payments);

  Future<UnmodifiableListView<Product>> getStoreProductsAsync(UnmodifiableListView<String> productIds);
}

class PaymentResult {
  final PaymentStatus status;
  final PaymentOption option;
  final Product product;
  final Object billingData;

  PaymentResult(this.status, { this.option, this.product, this.billingData });

  PaymentResult clone({PaymentStatus status, PaymentOption option,
    Product product, Object billingData})
    => PaymentResult(status ?? this.status, 
      option: option ?? this.option,
      product: product ?? this.product,
      billingData: billingData ?? this.billingData);
}