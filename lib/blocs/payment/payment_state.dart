part of 'payment_bloc.dart';

abstract class PaymentState extends Equatable {
  final UnmodifiableListView<PaymentResult> products;

  PaymentState(this.products);

  @override
  List<Object> get props => [products];
}

class PaymentIdealState extends PaymentState {
  final UnmodifiableListView<PaymentOption> paymentOptions;

  PaymentIdealState(this.paymentOptions,
      {UnmodifiableListView<PaymentResult> products})
      : super(products);

  @override
  List<Object> get props => [paymentOptions, products];
}

class PaymentCompletedState extends PaymentState {
  PaymentCompletedState(UnmodifiableListView<PaymentResult> results)
      : super(results);
}

class PaymentEmptyState extends PaymentState {
  PaymentEmptyState({UnmodifiableListView<PaymentResult> products})
      : super(products);
}

class PaymentErrorState extends PaymentState {
  final String message;

  PaymentErrorState({this.message,
      UnmodifiableListView<PaymentResult> products})
      : super(products);

  @override
  List<Object> get props => [message];
}

class PaymentLoadingState extends PaymentState {
  final int progress;

  PaymentLoadingState({this.progress,
      UnmodifiableListView<PaymentResult> products})
      : super(products);

  @override
  List<Object> get props => [progress];
}
