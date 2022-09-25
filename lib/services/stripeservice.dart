import 'dart:collection';

import 'package:dev_libraries/contracts/ecommerce/paymentservice.dart';
import 'package:dev_libraries/models/payment.dart';
import 'package:dev_libraries/models/products/product.dart';
import 'package:dev_libraries/models/creditcard.dart' as cc;
import 'package:rxdart/rxdart.dart';
//import 'package:stripe_payment/stripe_payment.dart';

// class StripeService extends PaymentService {
//   final ReplaySubject<UnmodifiableListView<PaymentResult>> _purchasesSubject = ReplaySubject<UnmodifiableListView<PaymentResult>>();

//   @override
//   Stream<UnmodifiableListView<PaymentResult>> get purchases => _purchasesSubject.stream;

//   StripeService(String key, String merchantId, { String androidPayMode = "test" }) {
//     StripePayment.setOptions(StripeOptions(
//         publishableKey: key,
//         merchantId: merchantId,
//         androidPayMode: androidPayMode));
//   }

//   @override
//   Future<void> pay(PaymentOption paymentOption, UnmodifiableListView<Product> products) async {
//     var total = products.fold(0.0, (double prev, current) => prev + current.price);
//     var currencyCode = products.first.currencyCode;

//     switch(paymentOption)
//     {
//       case PaymentOption.GooglePay:
//       case PaymentOption.ApplePay:
//         await StripePayment.paymentRequestWithNativePay(
//           androidPayOptions: AndroidPayPaymentRequest(
//             lineItems: products.map((product) => LineItem(
//               currencyCode: product.currencyCode,
//               description: product.description,
//               unitPrice: product.price.toString()
//             )).toList(),
//             totalPrice: total.toString(),
//             currencyCode: currencyCode
//           ),
//           applePayOptions: ApplePayPaymentOptions(
//             countryCode: currencyCode,
//             currencyCode: currencyCode,
//             items: products.map((product) => ApplePayItem(label: product.name, amount: product.price.toString())).toList()
//           )
//         ).then((token) {
//           _purchasesSubject.add(UnmodifiableListView(
//             products.map((product) => PaymentResult(PaymentStatus.Started,
//               product: product,
//               option: paymentOption, billingData: token))
//             ));
//         });
//         break;
//       case PaymentOption.CreditCard:
//         await StripePayment.createTokenWithCard(CreditCard());
//         break;
//       case PaymentOption.PayPal:
//         throw Exception("$paymentOption not supported by StripeService");
//         break;
//     }
//   }

//   @override
//   Future<void> payWithCreditCard(cc.CreditCard creditCard, UnmodifiableListView<Product> products) async =>
//     await StripePayment.createTokenWithCard(CreditCard(number: creditCard.number, cvc: creditCard.ccv))
//       .then((value) => null);

//   @override
//   Future<UnmodifiableListView<PaymentResult>>
//   completeAllPayments(UnmodifiableListView<PaymentResult> products) async =>
//     await StripePayment.completeNativePayRequest().then((_)
//       => UnmodifiableListView(products.map((purchase)
//         => purchase.clone(status: PaymentStatus.Completed))));

//   @override
//   Future<PaymentResult?> completePayment(PaymentResult product) async =>
//      await StripePayment.completeNativePayRequest().then((_) => null);

//   @override
//   Future<UnmodifiableListView<Product>> getStoreProductsAsync(UnmodifiableListView<Product> products) =>
//     Future.value(products);

//   close() {
//     _purchasesSubject.close();
//   }
// }
