part of 'payment_bloc.dart';

enum PaymentEventIds {
  LoadPaymentOptions,
  LoadPayment,
  StartPayment,
  CancelPayment,

  PaymentSuccess,
  PaymentFailed
}

class PaymentEvent extends Equatable {
  final PaymentEventIds id;
  

  const PaymentEvent(this.id);

  @override
  List<Object> get props => [id];
}

class PayWithEvent extends PaymentEvent {
  final PaymentOption option;
  final UnmodifiableListView<Product> products;
  const PayWithEvent(PaymentEventIds id, this.option, this.products)
    : super(id);

  @override
  List<Object> get props => [id, option, products];
}

class PaymentResultEvent extends PaymentEvent {
  final PaymentResult paymentResult;

  const PaymentResultEvent(PaymentEventIds id, this.paymentResult)
    : super(id);

  factory PaymentResultEvent.create(PaymentEventIds id, PaymentOption option, 
    PaymentResult paymentResult) {
    return PaymentResultEvent(id, paymentResult);
  }

  @override
  List<Object> get props => [id, paymentResult];
}