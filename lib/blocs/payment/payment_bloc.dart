import 'dart:async';
import 'dart:collection';
import 'dart:io' show Platform;

import 'package:bloc/bloc.dart';
import 'package:dev_libraries/models/payment.dart';
import 'package:dev_libraries/models/products/product.dart';
import 'package:dev_libraries/models/products/receipt.dart';
import 'package:equatable/equatable.dart';

part 'payment_event.dart';
part 'payment_state.dart';

typedef ItemDelivery = Future<bool> Function(UnmodifiableListView<Receipt> product);

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  List<PaymentOption> _paymentOptions;
  PaymentService _paymentService;
  StreamSubscription _paymentSubscription;

  PaymentBloc(this._paymentService, ItemDelivery itemDeliveryHandler, {List<PaymentOption> paymentOptions})
      : _paymentOptions = paymentOptions ?? _loadPaymentOptions(),
        super(PaymentEmptyState()) {
    _paymentSubscription = _paymentService.purchases.listen((event) {
      //payments are handled in this order
      //1. intiate payment
      //2. deliver product
      //3. complete payment
      itemDeliveryHandler(event)
            .then((success) async { if(success) await _paymentService.completeAllPayments(event); })
            .catchError(() => add(PaymentResultEvent(PaymentEventIds.PaymentFailed, event)))
            .then((value) => add(PaymentResultEvent(PaymentEventIds.PaymentSuccess, event)));
    });
  }

  @override
  Stream<PaymentState> mapEventToState(
    PaymentEvent event,
  ) async* {
    switch (event.id) {
      case PaymentEventIds.LoadPaymentOptions:
        yield PaymentIdealState(UnmodifiableListView(_paymentOptions));
        break;
      case PaymentEventIds.LoadPayment:
        var paymentEvent = event as PayWithEvent;

        yield PaymentLoadingState();

        yield await _paymentService
            .getStoreProductsAsync(paymentEvent.products.map((product) => product.id))
            .then((products) => products.isEmpty
                ? PaymentEmptyState()
                : PaymentIdealState(_paymentOptions, products: products));
        break;
      case PaymentEventIds.StartPayment:
        var paymentEvent = (event as PayWithEvent);

        yield PaymentLoadingState();

        await _paymentService.pay(paymentEvent.option, paymentEvent.products);
        break;
      case PaymentEventIds.CancelPayment:
        yield PaymentErrorState(message: "Payment cancelled");
        break;
      case PaymentEventIds.PaymentSuccess:
        var paymentEvent = (event as PaymentResultEvent);
        yield PaymentIdealState(_paymentOptions, products: paymentEvent.receipts);
        break;
      case PaymentEventIds.PaymentFailed:
        yield PaymentErrorState(message: "");
        break;
    }
  }

  @override
  Future<void> close() {
    _paymentSubscription?.cancel();
    return super.close();
  }

  static List<PaymentOption> _loadPaymentOptions() {
    List<PaymentOption> paymentOptions = [];

    if (Platform.isIOS)
      paymentOptions.add(PaymentOption.ApplePay);
    else if (Platform.isAndroid)
      paymentOptions.add(PaymentOption.GooglePay);

    paymentOptions.add(PaymentOption.PayPal);
    paymentOptions.add(PaymentOption.CreditCard);

    return paymentOptions;
  }
}
