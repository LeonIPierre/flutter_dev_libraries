part of 'payment_bloc.dart';

enum PaymentEventIds {
  LoadPayment,
  StartPaymentStream,
  
  InitatePayment,
  CompletePayment,
  //VerifyPurchase,
  //DeliverPurchase,

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
  final PaymentService paymentService;
  final UnmodifiableListView<Product> products;
  final UnmodifiableListView<PaymentOption> paymentOptions;

  PaymentLoadEvent(this.paymentService, this.products, { this.paymentOptions }) : super(PaymentEventIds.LoadPayment);

  @override
  List<Object> get props => [products, paymentOptions];
}

class PaymentStartedEvent extends PaymentEvent {
  final PaymentService paymentService;
  final ItemDelivery itemDeliveryHandler;
  final VerifyPurchase verifyPurchaseHandler;
  final PaymentOption option;
  final UnmodifiableListView<Product> products;

  const PaymentStartedEvent(PaymentEventIds id, this.paymentService, this.option, 
    this.itemDeliveryHandler, this.verifyPurchaseHandler, this.products)
    : super(id);

  @override
  List<Object> get props => [id, option, products];
}

class PaymentCompletedEvent extends PaymentStartedEvent {
  final UnmodifiableListView<PaymentResult> paymentResults;

  PaymentCompletedEvent(PaymentService paymentService, 
    PaymentOption option, ItemDelivery itemDeliveryHandler, 
    VerifyPurchase verifyPurchaseHandler, UnmodifiableListView<Product> products, this.paymentResults) 
    : super(PaymentEventIds.CompletePayment, paymentService, option, itemDeliveryHandler, verifyPurchaseHandler, products);

  @override
  List<Object> get props => [option, products, paymentResults];
}

class PaymentResultEvent extends PaymentEvent {
  final UnmodifiableListView<PaymentResult> paymentResults;

  const PaymentResultEvent(PaymentEventIds id, this.paymentResults)
    : super(id);

  @override
  List<Object> get props => [id, paymentResults];
}