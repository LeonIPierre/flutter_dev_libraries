import 'dart:collection';

import 'package:dev_libraries/contracts/ecommerce/paymentservice.dart';
import 'package:dev_libraries/models/creditcard.dart';
import 'package:dev_libraries/models/payment.dart';
import 'package:dev_libraries/models/products/product.dart';
import 'package:rxdart/rxdart.dart';

class PayPalService extends PaymentService {
  final ReplaySubject<UnmodifiableListView<PaymentResult>> _purchasesSubject = ReplaySubject<UnmodifiableListView<PaymentResult>>();
  
  @override
  Stream<UnmodifiableListView<PaymentResult>> get purchases => _purchasesSubject.stream;

  @override
  Future<UnmodifiableListView<PaymentResult>> completeAllPayments(UnmodifiableListView<PaymentResult> payments) {
    _purchasesSubject.add(UnmodifiableListView(
      payments.map((result) => result.clone(status: PaymentStatus.Completed))
    ));

    return Future.value(payments);
  }

  @override
  Future<PaymentResult> completePayment(PaymentResult payment) => Future.value(payment);

  @override
  Future<UnmodifiableListView<Product>> getStoreProductsAsync(UnmodifiableListView<Product> products) =>
    Future.value(products);

  @override
  Future<void> pay(PaymentOption paymentOption, UnmodifiableListView<Product> products) {
    _purchasesSubject.add(UnmodifiableListView(
            products.map((product) => PaymentResult(PaymentStatus.Started, 
              product: product,
              option: paymentOption))
            ));
  }

  @override
  Future<void> payWithCreditCard(CreditCard creditCard, UnmodifiableListView<Product> products) {
    // TODO: implement payWithCreditCard
    throw UnimplementedError();
  }

  close() {
    _purchasesSubject.close();
  }
}