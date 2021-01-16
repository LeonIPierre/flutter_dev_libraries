import 'dart:async';
import 'dart:collection';

import 'package:dev_libraries/models/payment.dart';
import 'package:dev_libraries/models/products/product.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class InAppPurchaseService extends PaymentService {
  final InAppPurchaseConnection _connection = InAppPurchaseConnection.instance;

  @override
  Stream<UnmodifiableListView<PaymentResult>> get purchases => _connection.purchaseUpdatedStream
    .map((event) => _mapToPurchaseState(event));

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

      //TODO get current product status from my server
      return UnmodifiableListView(productDetailResponse.productDetails.map((details) => 
        Product(details.skProduct.productIdentifier, details.title, details.description,
              double.parse(details.price), currencyCode: details.skProduct.priceLocale.currencyCode)));
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

  UnmodifiableListView<PaymentResult> _mapToPurchaseState(List<PurchaseDetails> purchases) {
    //TODO get product based on purchase.productID
    //Receipt(purchase.purchaseID, null, , data: purchases))
    // purchases.map((purchase) => _mapPaymentStatus(purchase.status)
    //   .clone(
    //       product: Product(purchase.productID, 
    //       purchase.billingClientPurchase., description, 
    //       purchase.)));
    // return UnmodifiableListView(purchases.map((purchase) => 
    //   _mapPaymentStatus(purchase.status).clone()
    // ));
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
    //products.map((product) => completePayment(product));
    Future.wait(products.map((product) => completePayment(product)));
    return null;
  }
}