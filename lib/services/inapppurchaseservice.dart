import 'dart:async';
import 'dart:collection';

import 'package:dev_libraries/models/payment.dart';
import 'package:dev_libraries/models/products/product.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class InAppPurchaseService extends PaymentService {
  final InAppPurchaseConnection _connection = InAppPurchaseConnection.instance;

  @override
  Stream<UnmodifiableListView<PaymentResult>> get purchases => _connection.purchaseUpdatedStream
    .asyncMap((event) => _mapToPurchaseState(event));

  InAppPurchaseService() {
    InAppPurchaseConnection.enablePendingPurchases();
  }

  @override
  Future<UnmodifiableListView<Product>> getStoreProductsAsync(
      UnmodifiableListView<String> productIds) async {
    return await _connection.isAvailable().then((success) {
      if (!success) throw Exception("Failed to connect to store");

      return _connection.queryProductDetails(productIds.toSet());
    }).then((productDetailResponse) {
      if (productDetailResponse.error != null)
        throw Exception(productDetailResponse.error.message);

      return UnmodifiableListView(productDetailResponse.productDetails.map((details) {
        if(details.skProduct != null)
          return Product(details.id, details.title, details.description,
              double.parse(details.skProduct.price), currencyCode: details.skProduct.priceLocale.currencyCode);
        else if(details.skuDetail != null)
          return Product(details.id, details.title, details.description,
              double.parse(details.skuDetail.originalPrice));

        return null;
      }
      ));
    });
  }

  @override
  Future<void> pay(PaymentOption paymentOption,
      UnmodifiableListView<Product> products) async {
    switch (paymentOption) {
      case PaymentOption.ApplePay:
      case PaymentOption.GooglePay:
        return await _connection.isAvailable().then((success) {
          if (!success) throw Exception("Failed to connect to $paymentOption store");

          return _connection.queryProductDetails(products.map((product) => product.id));
          }).then((response) {
          if (response.error != null)
            throw Exception(response.error.message);

          Future.forEach(response.productDetails, (ProductDetails details) async {
            var success = await _connection.buyNonConsumable(purchaseParam: PurchaseParam(
                          productDetails: details,
                          applicationUserName: null,
                          sandboxTesting: true));

            if(!success)
              throw Exception("Could not start purchase for $details");

            return details;
          });
        });
        break;
      case PaymentOption.CreditCard:
      case PaymentOption.PayPal:
        throw Exception("InAppPurchases doesn't support $paymentOption");
        break;
    }
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
          return null;
      }
  }

  Future<UnmodifiableListView<PaymentResult>> _mapToPurchaseState(List<PurchaseDetails> purchases) async {
    return await getStoreProductsAsync(purchases.map((p) => p.productID))
      .then((products) {
        return UnmodifiableListView(products.map((product) {
          var purchase = purchases.firstWhere((p) => p.productID == product.id);
          return _mapPaymentStatus(purchase.status)
          .clone(product: product, billingData: purchase);
        }));
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
  Future<UnmodifiableListView<PaymentResult>> completeAllPayments(UnmodifiableListView<PaymentResult> products) {
    Future.wait(products.map((product) => completePayment(product)));
    return null;
  }
}