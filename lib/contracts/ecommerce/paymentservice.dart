
import 'package:dev_libraries/models/creditcard.dart';
import 'package:dev_libraries/models/payment.dart';
import 'package:dev_libraries/models/products/product.dart';

abstract class PaymentService {
  Stream<Iterable<PaymentResult>> get purchases;

  Future<void> pay(PaymentOption paymentOption, Iterable<Product> products);

  Future<void> payWithCreditCard(CreditCard creditCard, Iterable<Product> products);

  Future<PaymentResult?> completePayment(PaymentResult payment);

  Future<Iterable<PaymentResult>> completeAllPayments(Iterable<PaymentResult> payments);

  Future<Iterable<Product>> getStoreProductsAsync(Iterable<Product> products);
}
