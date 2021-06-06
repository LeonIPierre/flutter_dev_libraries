import 'package:dev_libraries/models/products/product.dart';
import 'package:equatable/equatable.dart';

//change to PurchaseState
enum PaymentStatus {
  None,
  Started,
  Cancelled,
  Error,
  Completed,

  //TODO: convert to using these
  Any,

  Purchased,

  Voided,

  Active,

  //Cancelled,

  InGracePeriod,

  OnHold,

  Paused,

  Expired
}

enum PaymentOption
{
  GooglePay,
  ApplePay,
  CreditCard,
  PayPal
}

//TODO convert to Purchase class
class PaymentResult extends Equatable {
  final String? id;
  final PaymentStatus status;
  final PaymentOption? option;
  final Product? product;
  final Object? billingData;
  final DateTime ?timestamp;

  PaymentResult(this.status, { this.id, this.option, this.product, this.billingData, this.timestamp });

  PaymentResult clone({PaymentStatus? status, PaymentOption? option,
    Product? product, Object? billingData})
    => PaymentResult(status ?? this.status, 
      option: option ?? this.option,
      product: product ?? this.product,
      billingData: billingData ?? this.billingData);

  @override
  List<Object?> get props => [status, option, product, billingData];

  @override
  String toString() => 'PaymentResult { id:$id, status: $status, option:$option, product:$product, billingData: $billingData, timestamp:$timestamp }';
}