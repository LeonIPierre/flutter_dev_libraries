import 'dart:async';
import 'dart:collection';

import 'package:dev_libraries/models/payment.dart';
import 'package:dev_libraries/models/products/product.dart';
import 'package:dev_libraries/models/products/receipt.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class InAppPurchaseService extends PaymentService {
  final InAppPurchaseConnection _connection = InAppPurchaseConnection.instance;

  @override
  Stream<UnmodifiableListView<Receipt>> get purchases => _connection.purchaseUpdatedStream
    .map((event) => _mapToPurchaseState(event));

  InAppPurchaseService() {
    InAppPurchaseConnection.enablePendingPurchases();
  }

  @override
  Future<UnmodifiableListView<Receipt>> getStoreProductsAsync(
      UnmodifiableListView<String> productIds) async {
    return await _connection.isAvailable().then((success) {
      if (!success) throw Exception("Failed to connect to store");

      return _connection.queryProductDetails(productIds.toSet());
    }).then((productDetailResponse) {
      if (productDetailResponse.error != null)
        throw Exception(productDetailResponse.error.message);

      //TODO get current product status from my server
      return UnmodifiableListView(productDetailResponse.productDetails.map((details) => 
        Receipt(details.id, Product(details.skProduct.productIdentifier, details.title, details.description,
              double.parse(details.price), details.skProduct.priceLocale.currencyCode), 
              PaymentStatus.None)));
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

  PaymentStatus _mapPaymentStatus(PurchaseStatus status) {
    switch (status) {
        case PurchaseStatus.pending:
          return PaymentStatus.Started;
        case PurchaseStatus.purchased:
         return PaymentStatus.Completed;
        case PurchaseStatus.error:
           return PaymentStatus.Cancelled;
        default:
          return null;
      }
  }

  UnmodifiableListView<Receipt> _mapToPurchaseState(List<PurchaseDetails> purchases) {
    //TODO get product based on purchase.productID
    return UnmodifiableListView(purchases.map((purchase) => 
      Receipt(purchase.purchaseID, null, _mapPaymentStatus(purchase.status), data: purchases)));
  }

  @override
  Future<void> completePayment(Receipt product) async {
    //TODO change to figure out if the product is a consumable or not
    var data = product.data as PurchaseDetails;

    if(data.pendingCompletePurchase)
        _connection.completePurchase(data);
  }

  @override
  Future<void> completeAllPayments(UnmodifiableListView<Receipt> products) {
    products.map((product) => completePayment(product));
  }
}