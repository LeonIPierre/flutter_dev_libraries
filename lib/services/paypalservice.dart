import 'package:dev_libraries/contracts/ecommerce/paymentservice.dart';
import 'package:dev_libraries/models/creditcard.dart';
import 'package:dev_libraries/models/payment.dart';
import 'package:dev_libraries/models/products/product.dart';
import 'package:rxdart/rxdart.dart';

class PayPalService extends PaymentService {
  final ReplaySubject<Iterable<PaymentResult>> _purchasesSubject =
      ReplaySubject<Iterable<PaymentResult>>();

  @override
  Stream<Iterable<PaymentResult>> get purchases => _purchasesSubject.stream;

  @override
  Future<Iterable<PaymentResult>> completeAllPayments(
      Iterable<PaymentResult> payments) {
    _purchasesSubject.add(payments
        .map((result) => result.clone(status: PaymentStatus.Completed)));

    return _purchasesSubject.last;
  }

  @override
  Future<PaymentResult> completePayment(PaymentResult payment) =>
      Future.value(payment);

  @override
  Future<Iterable<Product>> getStoreProductsAsync(Iterable<Product> products) =>
      Future.value(products);

  @override
  Future<void> pay(
      PaymentOption paymentOption, Iterable<Product> products) async {
    _purchasesSubject.add(products.map((product) => PaymentResult(
        PaymentStatus.Started,
        product: product,
        option: paymentOption)));
  }

  @override
  Future<void> payWithCreditCard(
      CreditCard creditCard, Iterable<Product> products) {
    // TODO: implement payWithCreditCard
    throw UnimplementedError();
  }

  close() {
    _purchasesSubject.close();
  }
}
