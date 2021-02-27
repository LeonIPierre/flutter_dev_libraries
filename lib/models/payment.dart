import 'package:dev_libraries/models/products/product.dart';
import 'package:equatable/equatable.dart';

enum PaymentStatus {
  None,
  Started,
  Cancelled,
  Error,
  Completed
}

enum PaymentOption
{
  GooglePay,
  ApplePay,
  CreditCard,
  PayPal
}

class PaymentResult extends Equatable {
  final PaymentStatus status;
  final PaymentOption option;
  final Product product;
  final Object billingData;

  PaymentResult(this.status, { this.option, this.product, this.billingData });

  PaymentResult clone({PaymentStatus status, PaymentOption option,
    Product product, Object billingData})
    => PaymentResult(status ?? this.status, 
      option: option ?? this.option,
      product: product ?? this.product,
      billingData: billingData ?? this.billingData);

  @override
  List<Object> get props => [status, option, product, billingData];

  @override
  String toString() => 'PaymentResult { status: $status, option:$option, product:$product, billingData: $billingData }';
}