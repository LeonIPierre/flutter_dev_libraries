import 'dart:async';
import 'dart:collection';
import 'dart:io' show Platform;

import 'package:bloc/bloc.dart';
import 'package:dev_libraries/contracts/ecommerce/paymentservice.dart';
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
      case PaymentEventIds.LoadPaymentOptions:
        var paymentEvent = event as PaymentLoadEvent;

        yield PaymentLoadingState();

        _paymentOptions = paymentEvent.paymentOptions ?? _loadPaymentOptions();

        yield await paymentEvent.paymentService
            .getStoreProductsAsync(paymentEvent.products)
            .then((products) => products.isEmpty
                ? PaymentEmptyState()
                : PaymentIdealState(UnmodifiableListView(_paymentOptions),
                    products: UnmodifiableListView(products.map((p) =>
                        PaymentResult(PaymentStatus.None, product: p)).toList())));
        break;
      case PaymentEventIds.PaymentStarted:
        var paymentEvent = event as PaymentProcessEvent;
        yield await paymentEvent.paymentService.pay(paymentEvent.option, paymentEvent.products)
          .then((_) => PaymentIdealState(UnmodifiableListView(_paymentOptions),
                    products: UnmodifiableListView(paymentEvent.products.map((p) =>
                        PaymentResult(PaymentStatus.Started, product: p)).toList())));
        break;
      case PaymentEventIds.PaymentProcessUpdated:
        var paymentEvent = event as PaymentCompletedEvent;
        yield await paymentEvent.paymentService.completeAllPayments(paymentEvent.paymentResults)
            .then((value) => paymentEvent.verifyPurchaseHandler(value))
            .then((value) => paymentEvent.itemDeliveryHandler(value))
            .then<PaymentState>((value) => PaymentCompletedState(UnmodifiableListView(paymentEvent.paymentResults.map((p) => p.clone(status: PaymentStatus.Completed)).toList())))
            .catchError(() => PaymentErrorState(message: "Payment cancelled", 
              products: UnmodifiableListView(paymentEvent.paymentResults.map((p) => p.clone(status: PaymentStatus.Error)).toList())));
        break;
      case PaymentEventIds.PaymentCompleted:
        var paymentEvent = event as PaymentResultEvent;

        yield PaymentCompletedState(paymentEvent.paymentResults);
        break;
      case PaymentEventIds.PaymentCancelled:
        yield PaymentErrorState(message: "Payment cancelled");
        break;
      case PaymentEventIds.PaymentFailed:
        yield PaymentErrorState(message: "");
        break;
      case PaymentEventIds.StartPaymentStream:
        var paymentEvent = event as PaymentProcessEvent;

        yield PaymentLoadingState();

        _paymentSubscription = paymentEvent.paymentService.purchases.listen((event) async {
          //payments are handled in this order
          // start payment
          // complete payment
          // verify payment in the current application
          // deliver item
          if(event.every((element) => element.status == PaymentStatus.None)) {
            add(PaymentProcessEvent(PaymentEventIds.PaymentStarted, paymentEvent.paymentService, 
              paymentEvent.option, paymentEvent.products,
              itemDeliveryHandler: paymentEvent.itemDeliveryHandler, 
              verifyPurchaseHandler: paymentEvent.verifyPurchaseHandler));
          } else if(event.every((element) => element.status == PaymentStatus.Started)) {
            add(PaymentCompletedEvent(paymentEvent.paymentService, 
              paymentEvent.option, paymentEvent.itemDeliveryHandler, 
              paymentEvent.verifyPurchaseHandler, event));
          } else if(event.every((element) => element.status == PaymentStatus.Completed)) {
            add(PaymentResultEvent(PaymentEventIds.PaymentCompleted, event));
          } else if(event.any((element) => element.status == PaymentStatus.Error)) {
            add(PaymentResultEvent(PaymentEventIds.PaymentFailed, event));
          }
        });

        add(PaymentProcessEvent(PaymentEventIds.PaymentStarted, paymentEvent.paymentService, 
              paymentEvent.option, paymentEvent.products, 
              itemDeliveryHandler: paymentEvent.itemDeliveryHandler, 
              verifyPurchaseHandler: paymentEvent.verifyPurchaseHandler));
        break;
      case PaymentEventIds.CompletePaymentStream:
        // TODO: Handle this case.
        break;
      case PaymentEventIds.PaymentProcessUpdated:
        // TODO: Handle this case.
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
