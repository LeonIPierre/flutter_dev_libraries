part of 'payment_bloc.dart';

enum PaymentEventIds {
  LoadPaymentOptions,

  StartPaymentStream,
  CompletePaymentStream,

  PaymentStarted,
  PaymentProcessUpdated,
  PaymentCompleted,
  PaymentCancelled,
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

  PaymentLoadEvent(this.paymentService, this.products, { this.paymentOptions }) 
  : super(PaymentEventIds.LoadPaymentOptions);

  @override
  List<Object> get props => [products, paymentOptions];
}

class PaymentProcessEvent extends PaymentEvent {
  final PaymentService paymentService;
  final ItemDelivery itemDeliveryHandler;
  final VerifyPurchase verifyPurchaseHandler;
  final PaymentOption option;
  final UnmodifiableListView<Product> products;

  const PaymentProcessEvent(PaymentEventIds id, this.paymentService, this.option, 
     this.products, { this.itemDeliveryHandler, this.verifyPurchaseHandler })
    : super(id);

  @override
  List<Object> get props => [id, option, products];
}

class PaymentCompletedEvent extends PaymentProcessEvent {
  final UnmodifiableListView<PaymentResult> paymentResults;

  PaymentCompletedEvent(PaymentService paymentService, 
    PaymentOption option, ItemDelivery itemDeliveryHandler, 
    VerifyPurchase verifyPurchaseHandler, this.paymentResults) 
    : super(PaymentEventIds.PaymentCompleted, paymentService, option, 
      UnmodifiableListView(paymentResults.map((p) => p.product).toList()),
      itemDeliveryHandler: itemDeliveryHandler,
      verifyPurchaseHandler: verifyPurchaseHandler);

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