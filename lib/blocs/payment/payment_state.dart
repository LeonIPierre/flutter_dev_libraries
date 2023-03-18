part of 'payment_bloc.dart';

abstract class PaymentState extends Equatable {
  final Iterable<PaymentResult>? products;

  PaymentState(this.products);

  @override
  List<Object?> get props => [products];
}

class PaymentIdealState extends PaymentState {
  final Iterable<PaymentOption> paymentOptions;

  PaymentIdealState(this.paymentOptions,
      {Iterable<PaymentResult>? products})
      : super(products);

  @override
  List<Object?> get props => [paymentOptions, products];
}

class PaymentCompletedState extends PaymentState {
  PaymentCompletedState(Iterable<PaymentResult> results)
      : super(results);

  @override
  List<Object?> get props => [products!.every((element) => element.status == PaymentStatus.Completed)];
}

class PaymentEmptyState extends PaymentState {
  PaymentEmptyState({Iterable<PaymentResult>? products})
      : super(products);
}

class PaymentErrorState extends PaymentState {
  final String? message;

  PaymentErrorState({this.message,
      Iterable<PaymentResult>? products})
      : super(products);

  @override
  List<Object?> get props => [products, message];
}

class PaymentLoadingState extends PaymentState {
  final int? progress;

  PaymentLoadingState({this.progress,
      Iterable<PaymentResult>? products})
      : super(products);

  @override
  List<Object?> get props => [products, progress];
}
