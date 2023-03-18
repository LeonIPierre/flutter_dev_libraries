import 'dart:async';
import 'dart:io' show Platform;

import 'package:bloc/bloc.dart';
import 'package:dev_libraries/contracts/ecommerce/paymentservice.dart';
import 'package:dev_libraries/models/payment.dart';
import 'package:dev_libraries/models/products/product.dart';
import 'package:equatable/equatable.dart';

part 'payment_event.dart';
part 'payment_state.dart';

typedef ItemDelivery = Future<bool> Function(
    Iterable<PaymentResult> products);

typedef VerifyPurchase = Future<Iterable<PaymentResult>> Function(
    Iterable<PaymentResult> products);

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  late Iterable<PaymentOption> _paymentOptions;

  PaymentBloc() : super(PaymentEmptyState()) {
    
    on<PaymentLoadEvent>((event, emit) async {
      emit(PaymentLoadingState());

      _paymentOptions = event.paymentOptions ?? _loadPaymentOptions();

      emit(await event.paymentService
            .getStoreProductsAsync(event.products)
            .then((products) => products.isEmpty
                ? PaymentEmptyState()
                : PaymentIdealState(_paymentOptions,
                    products: products.map((p) =>
                        PaymentResult(PaymentStatus.None, product: p)))));
    });

    on<PaymentProcessStartedEvent>((event, emit) async {
      emit(await event.paymentService.pay(event.option, event.products)
        .then((_) => PaymentIdealState(_paymentOptions,
                  products: event.products.map((p) =>
                      PaymentResult(PaymentStatus.Started, product: p)))));
    });

    on<PaymentCompletedEvent>((event, emit) async {
      emit(await event.paymentService.completeAllPayments(event.paymentResults!)
            .then((value) => event.verifyPurchaseHandler!(value))
            .then((value) => event.itemDeliveryHandler!(value))
            .then<PaymentState>((value) => PaymentCompletedState(event.paymentResults!.map((p) => p.clone(status: PaymentStatus.Completed))))
            .catchError((_) => PaymentErrorState(message: "Payment cancelled", 
              products: event.paymentResults!.map((p) => p.clone(status: PaymentStatus.Error)))));
    });

    on<PaymentStreamEvent>((event, emit) async {
      emit(PaymentLoadingState());

      emit.forEach(event.paymentService.purchases, 
        onData: (Iterable<PaymentResult> paymentResults) {
          if(paymentResults.every((element) => element.status == PaymentStatus.None)) {
            return PaymentIdealState(_paymentOptions,
                  products: event.products.map((p) => PaymentResult(PaymentStatus.Started, product: p)));
          } else if(paymentResults.every((element) => element.status == PaymentStatus.Started)) {
            return PaymentLoadingState(products: paymentResults);
          } else if(paymentResults.every((element) => element.status == PaymentStatus.Completed)) {
            return PaymentCompletedState(paymentResults);
          } else if(paymentResults.any((element) => element.status == PaymentStatus.Error)) {
            return  PaymentErrorState(products: paymentResults);
          }

          return PaymentErrorState();
        });

      await event.paymentService.pay(event.option, event.products);
    });
  }

  static Iterable<PaymentOption> _loadPaymentOptions() {
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

    return paymentOptions;
  }
}
