import 'dart:collection';

import 'package:dev_libraries/models/product.dart';
import 'package:stripe_payment/stripe_payment.dart';

class StripeService {
  //final String _key = "pk_test_51HXudfDFekk8UURAVXOvFA7FkeSomfkHnHJXi8H5ny2dsyhLiPWybH6CwJz8kDx3xQiDbNqQsitzWajs9xzfPTuD00QajZD4c7";
  final String _key;
  final String _merchantId;
  final String androidPayMode;

  StripeService(this._key, this._merchantId, { this.androidPayMode = "test" });

  void initialize() {
    StripePayment.setOptions(StripeOptions(
        publishableKey: _key,
        merchantId: _merchantId, //YOUR_MERCHANT_ID
        androidPayMode: androidPayMode));
  }

  Future<Token> pay(UnmodifiableListView<Product> products, CreditCard card) => StripePayment.createTokenWithCard(
        card,
      );
    

  Future<Token> payNatively(UnmodifiableListView<Product> products) async {
    var total = products.fold(0.0, (double prev, current) => prev + current.price);
    var currencyCode = products.first.currencyCode;

    return await StripePayment.paymentRequestWithNativePay(
      androidPayOptions: AndroidPayPaymentRequest(
        lineItems: products.map((product) => LineItem(
          currencyCode: product.currencyCode,
          description: product.description,
          unitPrice: product.price.toString()
        )),
        totalPrice: total.toString(),
        currencyCode: currencyCode,
      ),
      applePayOptions: ApplePayPaymentOptions(
        countryCode: currencyCode,
        currencyCode: currencyCode,
        items: products.map((product) => ApplePayItem(label: product.name, amount: product.price.toString()))
      ),
    ).then((token) async => await StripePayment.completeNativePayRequest().then((_) => token));
  }
}
