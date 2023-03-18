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
  List<Object?> get props => [id];
}

class PaymentLoadEvent extends PaymentEvent {
  final PaymentService paymentService;
  final Iterable<Product> products;
  final Iterable<PaymentOption>? paymentOptions;

  PaymentLoadEvent(this.paymentService, this.products, { this.paymentOptions }) 
  : super(PaymentEventIds.LoadPaymentOptions);

  @override
  List<Object?> get props => [products, paymentOptions];
}

class PaymentProcessStartedEvent extends PaymentEvent {
  final PaymentService paymentService;
  final ItemDelivery? itemDeliveryHandler;
  final VerifyPurchase? verifyPurchaseHandler;
  final PaymentOption option;
  final Iterable<Product> products;

  const PaymentProcessStartedEvent(PaymentEventIds id, this.paymentService, this.option, 
     this.products, { this.itemDeliveryHandler, this.verifyPurchaseHandler })
    : super(id);

  @override
  List<Object?> get props => [id, option, products];
}

class PaymentStreamEvent extends PaymentProcessStartedEvent {
  PaymentStreamEvent(PaymentService paymentService, PaymentOption option, Iterable<Product> products) 
  : super(PaymentEventIds.StartPaymentStream, paymentService, option, products);
}

class PaymentCompletedEvent extends PaymentProcessStartedEvent {
  final Iterable<PaymentResult>? paymentResults;

  PaymentCompletedEvent(PaymentService paymentService, 
    PaymentOption option, ItemDelivery itemDeliveryHandler, 
    VerifyPurchase verifyPurchaseHandler, this.paymentResults) 
    : super(PaymentEventIds.PaymentCompleted, paymentService, option, 
      paymentResults!.map((p) => p.product!).toList(),
      itemDeliveryHandler: itemDeliveryHandler,
      verifyPurchaseHandler: verifyPurchaseHandler);

  @override
  List<Object?> get props => [option, products, paymentResults];
}

class PaymentResultEvent extends PaymentEvent {
  final Iterable<PaymentResult> paymentResults;

  const PaymentResultEvent(PaymentEventIds id, this.paymentResults)
    : super(id);

  @override
  List<Object> get props => [id, paymentResults];
}