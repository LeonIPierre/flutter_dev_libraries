part of 'payment_bloc.dart';

enum PaymentEventIds {
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

class PaymentLoadEvent extends PaymentEvent {
  final UnmodifiableListView<Product> products;
  final List<PaymentOption> paymentOptions;

  PaymentLoadEvent(this.products, { this.paymentOptions }) : super(PaymentEventIds.LoadPayment);
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
  final UnmodifiableListView<PaymentResult> paymentResults;

  const PaymentResultEvent(PaymentEventIds id, this.paymentResults)
    : super(id);

  @override
  List<Object> get props => [id, paymentResults];
}