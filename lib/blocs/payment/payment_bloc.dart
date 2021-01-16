import 'dart:async';
import 'dart:collection';
import 'dart:io' show Platform;

import 'package:bloc/bloc.dart';
import 'package:dev_libraries/models/payment.dart';
import 'package:dev_libraries/models/products/product.dart';
import 'package:equatable/equatable.dart';

part 'payment_event.dart';
part 'payment_state.dart';

typedef ItemDelivery = Future<bool> Function(UnmodifiableListView<PaymentResult> products);

typedef VerifyPurchase = Future<UnmodifiableListView<PaymentResult>> Function(UnmodifiableListView<PaymentResult> products);

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  List<PaymentOption> _paymentOptions;
  PaymentService _paymentService;
  StreamSubscription _paymentSubscription;

  PaymentBloc(this._paymentService, ItemDelivery itemDeliveryHandler, 
  VerifyPurchase verifyPurchaseHandler,
  {List<PaymentOption> paymentOptions})
      : _paymentOptions = paymentOptions ?? _loadPaymentOptions(),
        super(PaymentEmptyState()) {
    _paymentSubscription = _paymentService.purchases.listen((event) async {
      //payments are handled in this order
      // complete payment
      // verify payment
      // deliver item
      await _paymentService.completeAllPayments(event)
        .then((payments) => verifyPurchaseHandler(payments))
        //.catchError(() => add(PaymentResultEvent(PaymentEventIds.PaymentFailed, event)))
        //.then((value) => add(PaymentResultEvent(PaymentEventIds.PaymentSuccess, null, event)));
        .then((value) => itemDeliveryHandler(value));
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
                : PaymentIdealState(_paymentOptions, 
                  products: 
                    UnmodifiableListView(products.map((p) => PaymentResult(PaymentStatus.None, product: p)))));
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
        
        yield PaymentIdealState(_paymentOptions, 
          products: UnmodifiableListView([paymentEvent.paymentResult]));
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

    //Platform calls fail when called from a web project
    try {
      if (Platform.isIOS)
        paymentOptions.add(PaymentOption.ApplePay);
      else if (Platform.isAndroid)
        paymentOptions.add(PaymentOption.GooglePay);

    } catch(Exception) {
    }

    paymentOptions.add(PaymentOption.PayPal);
    paymentOptions.add(PaymentOption.CreditCard);

    return paymentOptions;
  }
}
