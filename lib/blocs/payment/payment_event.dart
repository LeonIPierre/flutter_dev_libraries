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
  const PayWithEvent(PaymentEventIds id, this.option, this.products) : super(id);

  @override
  List<Object> get props => [id, option, products];
}

class PaymentResultEvent extends PaymentEvent {
  final UnmodifiableListView<Receipt> receipts;
  const PaymentResultEvent(PaymentEventIds id, this.receipts) : super(id);

  @override
  List<Object> get props => [id, receipts];
}