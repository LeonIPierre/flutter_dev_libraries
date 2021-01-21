part of 'payment_bloc.dart';

abstract class PaymentState extends Equatable {
  @override
  List<Object> get props => [];
}

class PaymentIdealState extends PaymentState {
  final UnmodifiableListView<PaymentOption> paymentOptions;
  final UnmodifiableListView<PaymentResult> products;
   
  PaymentIdealState(this.paymentOptions, { this.products });
  
  @override
  List<Object> get props => [paymentOptions, products];
}

class PaymentCompletedState extends PaymentState {
  final UnmodifiableListView<PaymentResult> results;

  PaymentCompletedState(this.results);

  @override
  List<Object> get props => [results];
}

class PaymentEmptyState extends PaymentState {}

class PaymentErrorState extends PaymentState {
  final String message;
  PaymentErrorState({this.message});

  @override
  List<Object> get props => [message];
}

class PaymentLoadingState extends PaymentState {
  final int progress;
  PaymentLoadingState({this.progress});

  @override
  List<Object> get props => [progress];
}