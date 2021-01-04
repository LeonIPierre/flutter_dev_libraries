import 'dart:collection';

import 'package:dev_libraries/models/payment.dart';
import 'package:dev_libraries/models/products/product.dart';
import 'package:dev_libraries/models/products/receipt.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stripe_payment/stripe_payment.dart';

class StripeService extends PaymentService {
  final ReplaySubject<UnmodifiableListView<Receipt>> _purchasesSubject = ReplaySubject<UnmodifiableListView<Receipt>>();

  @override
  Stream<UnmodifiableListView<Receipt>> get purchases => _purchasesSubject.stream;

  StripeService(String key, String merchantId, { String androidPayMode = "test" }) {
    StripePayment.setOptions(StripeOptions(
        publishableKey: key,
        merchantId: merchantId,
        androidPayMode: androidPayMode));
  }

  @override
  Future<void> pay(PaymentOption paymentOption, UnmodifiableListView<Product> products) async {
    var total = products.fold(0.0, (double prev, current) => prev + current.price);
    var currencyCode = products.first.currencyCode;

    switch(paymentOption)
    {
      case PaymentOption.GooglePay:
      case PaymentOption.ApplePay:
        await StripePayment.paymentRequestWithNativePay(
          androidPayOptions: AndroidPayPaymentRequest(
            lineItems: products.map((product) => LineItem(
              currencyCode: product.currencyCode,
              description: product.description,
              unitPrice: product.price.toString()
            )),
            totalPrice: total.toString(),
            currencyCode: currencyCode
          ),
          applePayOptions: ApplePayPaymentOptions(
            countryCode: currencyCode,
            currencyCode: currencyCode,
            items: products.map((product) => ApplePayItem(label: product.name, amount: product.price.toString()))
          )
        );
        break;
      case PaymentOption.CreditCard:
        //await StripePayment.createTokenWithCard(CreditCard());
        break;
      case PaymentOption.PayPal:
        throw Exception("$paymentOption not supporte by StripeService");
        break;
    }
  } 

  @override
  Future<void> completeAllPayments(UnmodifiableListView<Receipt> products) async =>
    await StripePayment.completeNativePayRequest();
  
  @override
  Future<void> completePayment(Receipt product) async => await StripePayment.completeNativePayRequest();
  
  @override
  Future<UnmodifiableListView<Receipt>> getStoreProductsAsync(UnmodifiableListView<String> productIds) {
      // TODO: implement getStoreProductsAsync
      throw UnimplementedError();
  }

  close() {
    _purchasesSubject.close();
  }
}
