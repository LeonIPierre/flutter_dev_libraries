import 'dart:async';
import 'dart:collection';
import 'dart:io' show Platform;

import 'package:bloc/bloc.dart';
import 'package:dev_libraries/models/payment.dart';
import 'package:dev_libraries/models/products/product.dart';
import 'package:equatable/equatable.dart';

part 'payment_event.dart';
part 'payment_state.dart';

typedef ItemDelivery = Future<bool> Function(
    UnmodifiableListView<PaymentResult> products);

typedef VerifyPurchase = Future<UnmodifiableListView<PaymentResult>> Function(
    UnmodifiableListView<PaymentResult> products);

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  UnmodifiableListView<PaymentOption> _paymentOptions;
  StreamSubscription _paymentSubscription;

  PaymentBloc() : super(PaymentEmptyState());

  @override
  Stream<PaymentState> mapEventToState(PaymentEvent event) async* {
    switch (event.id) {
      case PaymentEventIds.LoadPayment:
        var paymentEvent = event as PaymentLoadEvent;

        yield PaymentLoadingState();

        _paymentOptions = paymentEvent.paymentOptions ?? _loadPaymentOptions();

        yield await paymentEvent.paymentService
            .getStoreProductsAsync(paymentEvent.products)
            .then((products) => products.isEmpty
                ? PaymentEmptyState()
                : PaymentIdealState(UnmodifiableListView(_paymentOptions),
                    products: UnmodifiableListView(products.map((p) =>
                        PaymentResult(PaymentStatus.None, product: p)))));
        break;
      case PaymentEventIds.InitatePayment:
        var paymentEvent = event as PaymentStartedEvent;
        await paymentEvent.paymentService.pay(paymentEvent.option, paymentEvent.products)
          .then((_) => PaymentIdealState(UnmodifiableListView(_paymentOptions),
                    products: UnmodifiableListView(paymentEvent.products.map((p) =>
                        PaymentResult(PaymentStatus.Started, product: p)))));
        break;
      case PaymentEventIds.CompletePayment:
        var paymentEvent = event as PaymentCompletedEvent;
        await paymentEvent.paymentService.completeAllPayments(paymentEvent.paymentResults)
            .then((value) => paymentEvent.verifyPurchaseHandler(value))
            .then((value) => paymentEvent.itemDeliveryHandler(value))
            .then((value) => add(PaymentResultEvent(PaymentEventIds.PaymentSuccess, 
            UnmodifiableListView(paymentEvent.paymentResults.map((p) => p.clone(status: PaymentStatus.Completed)))
            )))
            .catchError(() => add(PaymentResultEvent(PaymentEventIds.PaymentFailed, 
            UnmodifiableListView(paymentEvent.paymentResults.map((p) => p.clone(status: PaymentStatus.Error))))));
        break;
      case PaymentEventIds.PaymentSuccess:
        var paymentEvent = event as PaymentResultEvent;

        yield PaymentIdealState(_paymentOptions, products: paymentEvent.paymentResults);
        break;
      case PaymentEventIds.CancelPayment:
        yield PaymentErrorState(message: "Payment cancelled");
        break;
      case PaymentEventIds.PaymentFailed:
        yield PaymentErrorState(message: "");
        break;
      case PaymentEventIds.StartPaymentStream:
        var paymentEvent = event as PaymentStartedEvent;

        yield PaymentLoadingState();

        _paymentSubscription = paymentEvent.paymentService.purchases.listen((event) async {
          //payments are handled in this order
          // start payment
          // complete payment
          // verify payment in the current application
          // deliver item
          if(event.every((element) => element.status == PaymentStatus.None)) {
            add(PaymentStartedEvent(PaymentEventIds.InitatePayment, paymentEvent.paymentService, 
              paymentEvent.option, paymentEvent.itemDeliveryHandler, 
              paymentEvent.verifyPurchaseHandler, paymentEvent.products));
          } else if(event.every((element) => element.status == PaymentStatus.Started)) {
            add(PaymentCompletedEvent(paymentEvent.paymentService, 
              paymentEvent.option, paymentEvent.itemDeliveryHandler, 
              paymentEvent.verifyPurchaseHandler, paymentEvent.products, event));
          } else if(event.every((element) => element.status == PaymentStatus.Completed)) {
            add(PaymentResultEvent(PaymentEventIds.PaymentSuccess, event));
          }
          else if(event.any((element) => element.status == PaymentStatus.Error)) {
            add(PaymentResultEvent(PaymentEventIds.PaymentFailed, event));
          }
        });

        add(PaymentStartedEvent(PaymentEventIds.InitatePayment, paymentEvent.paymentService, 
              paymentEvent.option, paymentEvent.itemDeliveryHandler, 
              paymentEvent.verifyPurchaseHandler, paymentEvent.products));
        break;
    }
  }

  @override
  Future<void> close() {
    _paymentSubscription?.cancel();
    return super.close();
  }

  static UnmodifiableListView<PaymentOption> _loadPaymentOptions() {
    List<PaymentOption> paymentOptions = [];

    //Platform calls fail when called from a web project
    try {
      if (Platform.isIOS)
        paymentOptions.add(PaymentOption.ApplePay);
      else if (Platform.isAndroid)
        paymentOptions.add(PaymentOption.GooglePay);
    } catch (Exception) {}

    paymentOptions.add(PaymentOption.PayPal);
    paymentOptions.add(PaymentOption.CreditCard);

    return UnmodifiableListView(paymentOptions);
  }
}
