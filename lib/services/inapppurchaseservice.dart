import 'dart:async';
import 'dart:collection';

import 'package:dev_libraries/contracts/ecommerce/paymentservice.dart';
import 'package:dev_libraries/models/creditcard.dart';
import 'package:dev_libraries/models/payment.dart';
import 'package:dev_libraries/models/products/product.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class InAppPurchaseService extends PaymentService {
  final InAppPurchase _connection = InAppPurchase.instance;

  @override
  Stream<Iterable<PaymentResult>> get purchases => _connection.purchaseStream
    .asyncMap((event) => _mapToPurchaseState(event));

  InAppPurchaseService() {
    //InAppPurchase..enablePendingPurchases();
  }

  @override
  Future<Iterable<Product>> getStoreProductsAsync(
      Iterable<Product> products) async {
    return await _connection.isAvailable().then((success) {
      if (!success) throw Exception("Failed to connect to store");

      return _connection.queryProductDetails(products.map((product) => product.id).toSet());
    }).then((productDetailResponse) {
      if (productDetailResponse.error != null)
        throw Exception(productDetailResponse.error!.message);

      return productDetailResponse.productDetails.map((details) {
        return Product(details.id, details.title, details.description, double.parse(details.price));
      });
    });
  }

  @override
  Future<void> pay(PaymentOption paymentOption,
      Iterable<Product> products) async {
    switch (paymentOption) {
      case PaymentOption.ApplePay:
      case PaymentOption.GooglePay:
        return await _connection.isAvailable().then((success) {
          if (!success) throw Exception("Failed to connect to $paymentOption store");

          return _connection.queryProductDetails(products.map((product) => product.id).toSet());
          }).then((response) {
          if (response.error != null)
            throw Exception(response.error!.message);

          Future.forEach(response.productDetails, (ProductDetails details) async {
            var success = await _connection.buyNonConsumable(purchaseParam: PurchaseParam(
                          productDetails: details,
                          applicationUserName: null));

            if(!success)
              throw Exception("Could not start purchase for $details");

            return details;
          });
        });
      case PaymentOption.CreditCard:
      case PaymentOption.PayPal:
        throw Exception("InAppPurchases doesn't support $paymentOption");
    }
  }

  @override
  Future<void> payWithCreditCard(CreditCard creditCard, Iterable<Product> products) {
    // TODO: implement payWithCreditCard
    throw UnimplementedError();
  }

  PaymentResult _mapPaymentStatus(PurchaseStatus status) {
    switch (status) {
        case PurchaseStatus.pending:
          return PaymentResult(PaymentStatus.Started);
        case PurchaseStatus.purchased:
         return PaymentResult(PaymentStatus.Completed);
        case PurchaseStatus.error:
           return PaymentResult(PaymentStatus.Cancelled);
        default:
          throw Exception("InAppPurchases doesn't support $status");
      }
  }

  Future<Iterable<PaymentResult>> _mapToPurchaseState(Iterable<PurchaseDetails> purchases) async {
    return await getStoreProductsAsync(purchases.map((p) => Product(p.productID, '', '', 0)))
      .then((products) {
        return products.map((product) {
          var purchase = purchases.firstWhere((p) => p.productID == product.id);
          return _mapPaymentStatus(purchase.status)
          .clone(product: product, billingData: purchase);
        });
      });
  }

  @override
  Future<PaymentResult> completePayment(PaymentResult payment) async {
    //TODO change to figure out if the product is a consumable or not
    var data = payment.billingData as PurchaseDetails;

    if(data.pendingCompletePurchase)
        _connection.completePurchase(data).then((value) => value);

    return payment;
  }

  @override
  Future<Iterable<PaymentResult>> completeAllPayments(Iterable<PaymentResult> products) {
    return Future.wait(products.map((product) => completePayment(product)))
      .then((value) => value);
  }
}